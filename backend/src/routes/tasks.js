const express = require('express');

const supabase = require('../supabaseClient');

const router = express.Router();

const allowedRanks = new Set(['E', 'D', 'C', 'B', 'A', 'S']);
const xpByRank = { E: 20, D: 35, C: 55, B: 80, A: 115, S: 160 };

function todayIsoDate() {
  return new Date().toISOString().slice(0, 10);
}

function isIsoDate(value) {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value);
}

function addDays(isoDate, days) {
  const date = new Date(`${isoDate}T00:00:00.000Z`);
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

function clampText(value, fallback = '') {
  return typeof value === 'string' ? value.trim() : fallback;
}

function normalizeTaskPayload(body, userId) {
  const title = clampText(body.title);
  const rank = clampText(body.rank, 'E').toUpperCase();
  const dueDate = clampText(body.due_date) || todayIsoDate();
  const estimatedMinutes = Number.parseInt(body.estimated_minutes ?? 30, 10);

  if (!title) {
    return { error: 'Task title is required.' };
  }

  if (!allowedRanks.has(rank)) {
    return { error: 'Rank must be one of E, D, C, B, A, or S.' };
  }

  if (!isIsoDate(dueDate)) {
    return { error: 'due_date must use YYYY-MM-DD format.' };
  }

  if (!Number.isInteger(estimatedMinutes) || estimatedMinutes < 0) {
    return { error: 'estimated_minutes must be a positive integer.' };
  }

  return {
    data: {
      user_id: userId,
      title,
      description: clampText(body.description),
      category: clampText(body.category, 'General') || 'General',
      difficulty: clampText(body.difficulty, 'Normal') || 'Normal',
      estimated_minutes: estimatedMinutes,
      target_metric: clampText(body.target_metric),
      success_criteria: clampText(body.success_criteria),
      notes: clampText(body.notes),
      reward: clampText(body.reward),
      rank,
      due_date: dueDate,
      is_complete: false,
      locked_at: new Date().toISOString(),
      commitment_version: 1,
    },
  };
}

function sendSupabaseError(res, error) {
  return res.status(500).json({
    error: 'Supabase request failed.',
    details: error.message,
  });
}

function dateRangeFromPeriod(period, anchor) {
  const anchorDate = new Date(`${anchor}T00:00:00.000Z`);

  if (period === 'week') {
    const day = anchorDate.getUTCDay();
    const mondayOffset = day === 0 ? -6 : 1 - day;
    const start = addDays(anchor, mondayOffset);
    return { start, end: addDays(start, 6) };
  }

  if (period === 'month') {
    const start = `${anchor.slice(0, 7)}-01`;
    const nextMonth = new Date(`${start}T00:00:00.000Z`);
    nextMonth.setUTCMonth(nextMonth.getUTCMonth() + 1);
    nextMonth.setUTCDate(0);
    return { start, end: nextMonth.toISOString().slice(0, 10) };
  }

  return null;
}

function summarizeTasks(tasks, start, end) {
  const byDate = new Map();
  const byCategory = {};
  const byRank = {};
  let completed = 0;
  let missed = 0;
  let xp = 0;

  for (const task of tasks) {
    const day = byDate.get(task.due_date) || { total: 0, completed: 0, xp: 0 };
    day.total += 1;
    byCategory[task.category] = (byCategory[task.category] || 0) + 1;
    byRank[task.rank] = (byRank[task.rank] || 0) + 1;

    if (task.is_complete) {
      completed += 1;
      day.completed += 1;
      day.xp += xpByRank[task.rank] || xpByRank.E;
      xp += xpByRank[task.rank] || xpByRank.E;
    } else if (task.due_date < todayIsoDate()) {
      missed += 1;
    }

    byDate.set(task.due_date, day);
  }

  let bestDay = null;
  let worstDay = null;
  let currentStreak = 0;
  let longestStreak = 0;
  let streakRun = 0;

  for (let date = start; date <= end; date = addDays(date, 1)) {
    const day = byDate.get(date) || { total: 0, completed: 0, xp: 0 };
    const completionRate = day.total === 0 ? 0 : day.completed / day.total;
    const enrichedDay = { date, ...day, completion_rate: completionRate };

    if (!bestDay || enrichedDay.completed > bestDay.completed) {
      bestDay = enrichedDay;
    }

    if (day.total > 0 && (!worstDay || completionRate < worstDay.completion_rate)) {
      worstDay = enrichedDay;
    }

    if (day.total > 0 && day.completed === day.total) {
      streakRun += 1;
      longestStreak = Math.max(longestStreak, streakRun);
    } else if (day.total > 0) {
      streakRun = 0;
    }
  }

  for (let date = todayIsoDate(); date >= start; date = addDays(date, -1)) {
    const day = byDate.get(date);
    if (!day || day.total === 0) {
      continue;
    }
    if (day.completed !== day.total) {
      break;
    }
    currentStreak += 1;
  }

  return {
    total_tasks: tasks.length,
    completed_tasks: completed,
    missed_tasks: missed,
    completion_rate: tasks.length === 0 ? 0 : completed / tasks.length,
    xp,
    current_streak: currentStreak,
    longest_streak: longestStreak,
    category_breakdown: byCategory,
    rank_breakdown: byRank,
    best_day: bestDay,
    worst_day: worstDay,
  };
}

router.get('/', async (req, res) => {
  const dueDate = req.query.date || todayIsoDate();

  if (!isIsoDate(dueDate)) {
    return res.status(400).json({ error: 'date must use YYYY-MM-DD format.' });
  }

  const { data, error } = await supabase
    .from('tasks')
    .select('*')
    .eq('user_id', req.user.id)
    .eq('due_date', dueDate)
    .order('created_at', { ascending: true });

  if (error) {
    return sendSupabaseError(res, error);
  }

  return res.json({ date: dueDate, tasks: data });
});

router.post('/', async (req, res) => {
  const payload = normalizeTaskPayload(req.body, req.user.id);

  if (payload.error) {
    return res.status(400).json({ error: payload.error });
  }

  const { data, error } = await supabase
    .from('tasks')
    .insert(payload.data)
    .select('*')
    .single();

  if (error) {
    return sendSupabaseError(res, error);
  }

  return res.status(201).json({ task: data });
});

router.patch('/:id/complete', async (req, res) => {
  if (req.body.is_complete !== true) {
    return res.status(409).json({ error: 'Tasks can only move from incomplete to complete.' });
  }

  const { data: task, error: lookupError } = await supabase
    .from('tasks')
    .select('*')
    .eq('id', req.params.id)
    .eq('user_id', req.user.id)
    .maybeSingle();

  if (lookupError) {
    return sendSupabaseError(res, lookupError);
  }

  if (!task) {
    return res.status(404).json({ error: 'Task was not found.' });
  }

  if (task.is_complete) {
    return res.status(409).json({ error: 'Completed tasks are locked and cannot be changed.' });
  }

  const { data, error } = await supabase
    .from('tasks')
    .update({ is_complete: true, completed_at: new Date().toISOString() })
    .eq('id', req.params.id)
    .eq('user_id', req.user.id)
    .eq('is_complete', false)
    .select('*')
    .single();

  if (error) {
    return sendSupabaseError(res, error);
  }

  return res.json({ task: data });
});

router.patch('/:id', (req, res) => {
  return res.status(405).json({ error: 'Tasks are committed at creation and cannot be edited.' });
});

router.delete('/:id', (req, res) => {
  return res.status(405).json({ error: 'Tasks are committed at creation and cannot be deleted.' });
});

router.get('/history', async (req, res) => {
  const start = req.query.start;
  const end = req.query.end;

  if (!isIsoDate(start) || !isIsoDate(end) || start > end) {
    return res.status(400).json({ error: 'start and end must be valid YYYY-MM-DD dates.' });
  }

  const { data, error } = await supabase
    .from('tasks')
    .select('*')
    .eq('user_id', req.user.id)
    .gte('due_date', start)
    .lte('due_date', end)
    .order('due_date', { ascending: false })
    .order('created_at', { ascending: true });

  if (error) {
    return sendSupabaseError(res, error);
  }

  return res.json({ start, end, tasks: data });
});

router.get('/reports', async (req, res) => {
  const period = req.query.period || 'week';
  const anchor = req.query.anchor || todayIsoDate();

  if (!['week', 'month'].includes(period)) {
    return res.status(400).json({ error: 'period must be week or month.' });
  }

  if (!isIsoDate(anchor)) {
    return res.status(400).json({ error: 'anchor must use YYYY-MM-DD format.' });
  }

  const range = dateRangeFromPeriod(period, anchor);
  const { data, error } = await supabase
    .from('tasks')
    .select('*')
    .eq('user_id', req.user.id)
    .gte('due_date', range.start)
    .lte('due_date', range.end)
    .order('due_date', { ascending: true });

  if (error) {
    return sendSupabaseError(res, error);
  }

  return res.json({
    period,
    start: range.start,
    end: range.end,
    ...summarizeTasks(data, range.start, range.end),
  });
});

router.get('/activity/summary', async (req, res) => {
  const days = Number.parseInt(req.query.days || '366', 10);

  if (!Number.isInteger(days) || days < 1 || days > 366) {
    return res.status(400).json({ error: 'days must be between 1 and 366.' });
  }

  const end = todayIsoDate();
  const start = addDays(end, -days + 1);

  const { data, error } = await supabase
    .from('tasks')
    .select('due_date,is_complete')
    .eq('user_id', req.user.id)
    .gte('due_date', start)
    .lte('due_date', end);

  if (error) {
    return sendSupabaseError(res, error);
  }

  const countsByDate = data.reduce((counts, task) => {
    const day = counts[task.due_date] || { total: 0, completed: 0 };
    day.total += 1;
    if (task.is_complete) {
      day.completed += 1;
    }
    counts[task.due_date] = day;
    return counts;
  }, {});

  const activity = Array.from({ length: days }, (_, index) => {
    const date = addDays(start, index);
    const counts = countsByDate[date] || { total: 0, completed: 0 };
    const completionRate = counts.total === 0 ? 0 : counts.completed / counts.total;

    return {
      date,
      total: counts.total,
      completed: counts.completed,
      completion_rate: completionRate,
      intensity: Math.min(4, counts.completed),
    };
  });

  return res.json({ start, end, activity });
});

module.exports = router;
