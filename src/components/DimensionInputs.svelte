<script>
  import { createEventDispatcher } from 'svelte';
  import { fly } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';
  import { getFieldLabels } from '../lib/materialData.js';

  export let profile;

  const dispatch = createEventDispatcher();

  let values = ['', '', '', '', ''];
  let prevProfile = profile;

  // При смене профиля — очищаем поля, как в didUpdateWidget
  $: if (profile !== prevProfile) {
    values = ['', '', '', '', ''];
    prevProfile = profile;
    notify();
  }

  $: labels = getFieldLabels(profile);
  $: activeCount = labels.filter((l) => l != null).length;

  function notify() {
    const nums = values.map((v) => {
      const parsed = parseFloat(String(v).replace(',', '.'));
      return Number.isFinite(parsed) ? parsed : 0;
    });
    dispatch('change', nums);
  }

  function onInput(index, e) {
    let text = e.target.value;
    // Разрешаем цифры и максимум одну точку/запятую, максимум 10 символов
    if (!/^\d*[.,]?\d*$/.test(text)) {
      e.target.value = values[index];
      return;
    }
    if (text.length > 10) {
      text = text.slice(0, 10);
    }
    values[index] = text;
    values = [...values]; // Исправлена реактивность массива в Svelte
    e.target.value = text;
    notify();
  }

  function onKeyDown(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      const inputs = Array.from(document.querySelectorAll('.dims-wrapper input'));
      const currentIndex = inputs.indexOf(e.target);
      if (currentIndex >= 0 && currentIndex < inputs.length - 1) {
        inputs[currentIndex + 1].focus();
        inputs[currentIndex + 1].select();
      } else {
        e.target.blur();
      }
    }
  }
</script>

<div class="dims-wrapper">
  {#key profile}
    <div
      class="dims"
      class:grid2={activeCount === 2}
      class:grid3={activeCount === 3}
      class:grid4={activeCount === 4}
      class:grid5={activeCount === 5}
      in:fly={{ y: 8, duration: 260, easing: cubicOut }}
    >
      {#each labels as label, i}
        {#if label != null}
          <label class="field">
            <span class="field-label">{label}</span>
            <div class="input-wrap">
              <input
                type="text"
                inputmode="decimal"
                placeholder="0"
                value={values[i]}
                on:input={(e) => onInput(i, e)}
                on:keydown={onKeyDown}
                on:focus={(e) => e.target.select()}
              />
              <span class="suffix">мм</span>
            </div>
          </label>
        {/if}
      {/each}
    </div>
  {/key}
</div>

<style>
  .dims-wrapper {
    position: relative;
    overflow: hidden;
    width: 100%;
  }
  .dims {
    display: grid;
    gap: 10px;
    width: 100%;
  }
  /* 2 поля: ровно по 50% ширины карточки */
  .dims.grid2 {
    grid-template-columns: repeat(2, 1fr);
  }
  /* 3 поля: ровно по 33.3% ширины карточки */
  .dims.grid3 {
    grid-template-columns: repeat(3, 1fr);
  }
  /* 4 поля: 2 ряда по 2 */
  .dims.grid4 {
    grid-template-columns: repeat(2, 1fr);
  }
  /* 5 полей: 3 в первом ряду (по 33.3%), 2 во втором (по 50%) на всю ширину */
  .dims.grid5 {
    grid-template-columns: repeat(6, 1fr);
  }
  .dims.grid5 .field:nth-child(-n+3) {
    grid-column: span 2;
  }
  .dims.grid5 .field:nth-child(n+4) {
    grid-column: span 3;
  }
  .field {
    display: flex;
    flex-direction: column;
    gap: 6px;
    min-width: 0;
  }
  .field-label {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-secondary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .input-wrap {
    position: relative;
    display: flex;
    align-items: center;
  }
  input {
    width: 100%;
    box-sizing: border-box;
    background: var(--surface-variant);
    border: 1px solid var(--divider);
    border-radius: var(--radius-input);
    padding: 12px 32px 12px 14px;
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
    font-family: inherit;
    transition: border-color 0.2s ease, background 0.2s ease;
  }
  input:focus {
    outline: none;
    border-color: var(--accent);
  }
  .suffix {
    position: absolute;
    right: 12px;
    font-size: 12px;
    color: var(--text-secondary);
    pointer-events: none;
  }
</style>
