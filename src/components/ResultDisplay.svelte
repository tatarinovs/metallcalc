<script>
  import { onDestroy } from 'svelte';
  import { fly, fade } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';
  import { calculateMassKg } from '../lib/calculator.js';

  export let volumeMm3 = null;
  export let densityGcm3 = null;
  export let linearMassKg = null;

  let copied = false;
  let copiedTimer;

  onDestroy(() => {
    clearTimeout(copiedTimer);
  });

  function formatValue(val, decimals) {
    if (val == null || !Number.isFinite(val)) return '0';
    let s = val.toFixed(decimals);
    if (s.includes('.')) {
      s = s.replace(/0*$/, '');
      if (s.endsWith('.')) s = s.slice(0, -1);
    }
    return s || '0';
  }

  function formatMass(kg) {
    if (kg < 0.001) return `${formatValue(kg * 1e6, 3)} мг`;
    if (kg < 1.0) return `${formatValue(kg * 1000, 3)} г`;
    if (kg >= 1000) return `${formatValue(kg / 1000, 3)} т`;
    return `${formatValue(kg, 3)} кг`;
  }

  $: hasResult = volumeMm3 != null && densityGcm3 != null;
  $: volumeCm3 = hasResult ? volumeMm3 / 1000.0 : null;
  $: massKg = hasResult ? calculateMassKg({ volumeMm3, densityGcm3 }) : null;
  $: massStr = massKg != null ? formatMass(massKg) : '';
  $: volumeStr =
    volumeCm3 != null
      ? volumeCm3 >= 1000
        ? `${formatValue(volumeCm3 / 1000, 3)} дм³`
        : `${formatValue(volumeCm3, 3)} см³`
      : '';
  $: linearMassStr = linearMassKg != null ? `${formatValue(linearMassKg, 3)} кг` : '---';

  function copy() {
    navigator.clipboard?.writeText(massStr).catch(() => {});
    copied = true;
    clearTimeout(copiedTimer);
    copiedTimer = setTimeout(() => (copied = false), 2000);
  }
</script>

<div class="result-container">
  {#if hasResult}
    <div
      class="result-card"
      in:fly={{ y: 12, duration: 280, easing: cubicOut }}
      out:fade={{ duration: 150 }}
    >
      <div class="result-header">
        <span class="result-label">Теоретическая масса</span>
        <button type="button" class="copy-btn" class:copied on:click={copy}>
          {#if copied}
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
              <path d="M9 16.2l-3.5-3.5L4 14.2 9 19.2 20 8.2l-1.5-1.5z" />
            </svg>
            Скопировано!
          {:else}
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M16 1H4a2 2 0 00-2 2v14h2V3h12V1zm3 4H8a2 2 0 00-2 2v14a2 2 0 002 2h11a2 2 0 002-2V7a2 2 0 00-2-2zm0 16H8V7h11v14z"
              />
            </svg>
            Копировать
          {/if}
        </button>
      </div>
      <div class="mass">{massStr}</div>
      <div class="divider" />
      <div class="chips">
        <div class="chip">
          <svg
            width="15"
            height="15"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path
              d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"
            />
            <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
            <line x1="12" y1="22.08" x2="12" y2="12" />
          </svg>
          <div class="chip-text">
            <span class="chip-label">Объём</span>
            <span class="chip-value">{volumeStr}</span>
          </div>
        </div>
        <div class="chip">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
            <path d="M2 12h20M6 8v8M18 8v8" stroke="currentColor" stroke-width="2" fill="none" />
          </svg>
          <div class="chip-text">
            <span class="chip-label">Вес 1 п.м.</span>
            <span class="chip-value">{linearMassStr}</span>
          </div>
        </div>
      </div>
    </div>
    {#if copied}
      <div
        class="snackbar"
        transition:fly={{ y: 24, duration: 250, easing: cubicOut }}
      >
        Скопировано: {massStr}
      </div>
    {/if}
  {:else}
    <div
      class="empty-card"
      in:fade={{ duration: 200 }}
      out:fade={{ duration: 120 }}
    >
      <svg
        width="30"
        height="30"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.8"
        stroke-linecap="round"
        stroke-linejoin="round"
        opacity="0.45"
      >
        <rect x="4" y="2" width="16" height="20" rx="2" />
        <line x1="8" y1="6" x2="16" y2="6" />
        <line x1="16" y1="14" x2="16" y2="18" />
        <path d="M16 10h.01" />
        <path d="M12 10h.01" />
        <path d="M8 10h.01" />
        <path d="M12 14h.01" />
        <path d="M8 14h.01" />
        <path d="M12 18h.01" />
        <path d="M8 18h.01" />
      </svg>
      <p>{densityGcm3 == null ? 'Выберите материал и введите размеры' : 'Введите все размеры для расчёта'}</p>
    </div>
  {/if}
</div>

<style>
  .result-container {
    position: relative;
  }
  .result-card {
    border-radius: var(--radius-card);
    border: 1.5px solid color-mix(in srgb, var(--accent) 40%, transparent);
    padding: 16px;
    background: linear-gradient(135deg, var(--result-grad-start), var(--result-grad-end));
    box-shadow: var(--shadow-card);
  }
  .result-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .result-label {
    font-size: 12px;
    font-weight: 500;
    letter-spacing: 0.8px;
    color: var(--text-secondary);
  }
  .copy-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 11px;
    font-weight: 500;
    color: var(--accent);
    background: color-mix(in srgb, var(--accent) 12%, transparent);
    border: 1px solid color-mix(in srgb, var(--accent) 30%, transparent);
    border-radius: var(--radius-sm);
    padding: 6px 10px;
    cursor: pointer;
    font-family: inherit;
    transition: background 0.15s ease, transform 0.1s ease, color 0.15s ease;
    user-select: none;
  }
  .copy-btn:hover {
    background: color-mix(in srgb, var(--accent) 20%, transparent);
  }
  .copy-btn:active {
    transform: scale(0.95);
  }
  .copy-btn.copied {
    background: var(--success-surface);
    border-color: var(--success);
    color: var(--success);
  }
  .mass {
    margin-top: 10px;
    font-size: 38px;
    font-weight: 700;
    letter-spacing: -0.5px;
    line-height: 1.1;
    color: var(--accent);
    transition: color 0.2s ease;
    user-select: text;
    -webkit-user-select: text;
    cursor: text;
  }
  .divider {
    margin: 10px 0;
    height: 1px;
    background: var(--divider);
  }
  .chips {
    display: flex;
    gap: 12px;
  }
  .chip {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: var(--surface-variant);
    border: 1px solid var(--divider);
    border-radius: var(--radius-input);
    min-width: 0;
    transition: background 0.15s ease;
  }
  .chip svg {
    flex-shrink: 0;
    color: var(--text-secondary);
  }
  .chip-text {
    display: flex;
    flex-direction: column;
    gap: 2px;
    min-width: 0;
  }
  .chip-label {
    font-size: 10px;
    color: var(--text-secondary);
  }
  .chip-value {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-primary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    user-select: text;
    -webkit-user-select: text;
    cursor: text;
  }
  .empty-card {
    height: 90px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    background: var(--surface);
    border: 1px solid var(--divider);
    border-radius: var(--radius-card);
    color: var(--text-secondary);
  }
  .empty-card p {
    margin: 0;
    font-size: 13px;
    text-align: center;
    opacity: 0.7;
    max-width: 80%;
  }
  .snackbar {
    position: fixed;
    left: 50%;
    transform: translateX(-50%);
    bottom: 24px;
    background: var(--accent-deep);
    color: #fff;
    text-align: center;
    padding: 10px 20px;
    border-radius: var(--radius-md);
    font-size: 14px;
    font-weight: 500;
    box-shadow: var(--shadow-toast);
    z-index: 100;
    pointer-events: none;
    white-space: nowrap;
  }
</style>
