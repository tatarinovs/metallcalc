<script context="module">
  import { writable } from 'svelte/store';
  export const activeDropdownId = writable(null);
</script>

<script>
  import { createEventDispatcher, onDestroy } from 'svelte';
  import { fly } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';

  export let id = null;
  export let label = '';
  export let value = null; // Текущее выбранное значение (id или объект)
  export let options = []; // [{ value, label, sublabel }]
  export let placeholder = 'Выберите вариант';
  export let disabled = false;

  const dispatch = createEventDispatcher();
  const internalId = Symbol();
  $: dropdownId = id || internalId;
  $: isOpen = $activeDropdownId === dropdownId;

  let containerEl;
  let triggerEl;
  let menuListEl;
  let menuStyle = '';

  $: selectedOption = options.find((o) => o.value === value) ?? null;

  $: if (disabled && isOpen) {
    close();
  }

  onDestroy(() => {
    if ($activeDropdownId === dropdownId) {
      activeDropdownId.set(null);
    }
  });

  function getSafeAreaInsets() {
    if (typeof window === 'undefined') return { top: 0, bottom: 0 };
    const appEl = document.querySelector('.app');
    if (appEl) {
      const style = window.getComputedStyle(appEl);
      const top = parseFloat(style.paddingTop) || 0;
      const bottom = parseFloat(style.paddingBottom) || 0;
      return { top, bottom };
    }
    return { top: 0, bottom: 0 };
  }

  function updateMenuPosition() {
    if (!triggerEl || !containerEl || typeof window === 'undefined') return;
    const triggerRect = triggerEl.getBoundingClientRect();
    const containerRect = containerEl.getBoundingClientRect();
    const vh = window.innerHeight;

    const insets = getSafeAreaInsets();
    const minTop = Math.max(12, insets.top + 8);
    const maxBottom = vh - Math.max(12, insets.bottom + 8);

    const approxItemHeight = 42;
    const padding = 12;
    const totalContentHeight = options.length * approxItemHeight + padding;
    const maxViewportHeight = Math.min(480, maxBottom - minTop);
    const targetHeight = Math.min(totalContentHeight, maxViewportHeight);

    const spaceBelow = maxBottom - triggerRect.bottom;
    const spaceAbove = triggerRect.top - minTop;

    const selIdx = options.findIndex((o) => o.value === value);
    const activeIndex = selIdx >= 0 ? selIdx : 0;

    // Для коротких списков (до 4 пунктов), если снизу достаточно места
    if (options.length <= 4 && spaceBelow >= totalContentHeight) {
      menuStyle = `top: calc(100% + 4px); bottom: auto; max-height: ${targetHeight}px;`;
      return;
    }

    // Поведение Flutter для больших списков / нехватки места:
    // Позиционируем меню выше, чтобы задействовать свободное место сверху
    // и выровнять выбранный элемент около строки вызова
    let idealTopViewport = triggerRect.top - (activeIndex * approxItemHeight);

    // Ограничиваем сверху с учетом safe-area-inset-top
    if (idealTopViewport < minTop) {
      idealTopViewport = minTop;
    }

    // Ограничиваем снизу с учетом safe-area-inset-bottom
    if (idealTopViewport + targetHeight > maxBottom) {
      idealTopViewport = Math.max(minTop, maxBottom - targetHeight);
    }

    const relativeTop = idealTopViewport - containerRect.top;
    menuStyle = `top: ${Math.round(relativeTop)}px; bottom: auto; max-height: ${targetHeight}px;`;
  }

  let focusedIndex = -1;

  function scrollToFocused() {
    setTimeout(() => {
      if (!menuListEl) return;
      const items = menuListEl.querySelectorAll('.menu-item');
      if (items[focusedIndex]) {
        items[focusedIndex].scrollIntoView({ block: 'nearest' });
      }
    }, 10);
  }

  function open() {
    if (disabled) return;
    activeDropdownId.set(dropdownId);
    const selIdx = options.findIndex((o) => o.value === value);
    focusedIndex = selIdx >= 0 ? selIdx : 0;
    updateMenuPosition();
    scrollToFocused();
  }

  function close() {
    if ($activeDropdownId === dropdownId) {
      activeDropdownId.set(null);
    }
  }

  function toggle() {
    if (disabled) return;
    if ($activeDropdownId === dropdownId) {
      close();
    } else {
      open();
    }
  }

  function select(opt) {
    close();
    dispatch('select', opt.value);
  }

  function onWindowClick(e) {
    if (isOpen && containerEl && !containerEl.contains(e.target)) {
      close();
    }
  }

  function onKeyDown(e) {
    if (!isOpen) return;

    if (e.key === 'Escape' || e.key === 'Tab') {
      close();
      return;
    }

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (options.length === 0) return;
      focusedIndex = (focusedIndex + 1) % options.length;
      scrollToFocused();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (options.length === 0) return;
      focusedIndex = (focusedIndex - 1 + options.length) % options.length;
      scrollToFocused();
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (focusedIndex >= 0 && focusedIndex < options.length) {
        select(options[focusedIndex]);
      }
    }
  }

  function onWindowResize() {
    if (isOpen) {
      updateMenuPosition();
    }
  }
</script>

<svelte:window on:click={onWindowClick} on:keydown={onKeyDown} on:resize={onWindowResize} />

<div class="dropdown-field" bind:this={containerEl} class:disabled>
  {#if label}
    <span class="field-label">{label}</span>
  {/if}

  <button
    type="button"
    class="trigger"
    class:open={isOpen}
    on:click={toggle}
    bind:this={triggerEl}
    {disabled}
  >
    <div class="trigger-content">
      {#if selectedOption}
        <span class="trigger-text">{selectedOption.label}</span>
        {#if selectedOption.sublabel}
          <span class="trigger-sub">{selectedOption.sublabel}</span>
        {/if}
      {:else}
        <span class="placeholder">{placeholder}</span>
      {/if}
    </div>
    <svg
      class="chevron"
      class:rotate={isOpen}
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="currentColor"
    >
      <path d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z" />
    </svg>
  </button>

  {#if isOpen}
    <div
      class="menu"
      style={menuStyle}
      transition:fly={{ y: -4, duration: 160, easing: cubicOut }}
    >
      <div class="menu-list" bind:this={menuListEl}>
        {#each options as opt, i}
          <button
            type="button"
            class="menu-item"
            class:active={opt.value === value}
            class:focused={i === focusedIndex}
            on:click|stopPropagation={() => select(opt)}
          >
            <span class="item-label">{opt.label}</span>
            {#if opt.sublabel}
              <span class="item-sub">{opt.sublabel}</span>
            {/if}
            {#if opt.value === value}
              <svg class="check" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
              </svg>
            {/if}
          </button>
        {/each}
      </div>
    </div>
  {/if}
</div>

<style>
  .dropdown-field {
    position: relative;
    display: flex;
    flex-direction: column;
    gap: 6px;
    width: 100%;
  }

  .field-label {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-secondary);
  }

  .trigger {
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    box-sizing: border-box;
    background: var(--surface-variant);
    border: 1px solid var(--divider);
    border-radius: var(--radius-input);
    padding: 12px 14px;
    font-size: 14px;
    font-family: inherit;
    color: var(--text-primary);
    text-align: left;
    outline: none;
    transition: all 0.2s ease;
  }

  .trigger:hover:not(:disabled) {
    border-color: color-mix(in srgb, var(--accent) 50%, var(--divider));
  }

  .trigger.open {
    border-color: var(--accent);
    box-shadow: var(--focus-ring);
  }

  .trigger:disabled {
    opacity: 0.55;
    cursor: not-allowed;
  }

  .trigger-content {
    display: flex;
    align-items: baseline;
    gap: 8px;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  }

  .trigger-text {
    font-weight: 500;
  }

  .trigger-sub {
    font-size: 12px;
    color: var(--text-secondary);
  }

  .placeholder {
    color: var(--text-secondary);
  }

  .chevron {
    flex-shrink: 0;
    color: var(--text-secondary);
    transition: transform 0.2s ease, color 0.2s ease;
  }

  .chevron.rotate {
    transform: rotate(180deg);
    color: var(--accent);
  }

  /* Всплывающее меню */
  .menu {
    position: absolute;
    top: calc(100% + 4px);
    left: 0;
    right: 0;
    z-index: 1000;
    background: var(--surface);
    border: 1px solid var(--divider);
    border-radius: var(--radius-md);
    box-shadow: var(--shadow-dropdown);
    overflow: hidden;
    backdrop-filter: blur(12px);
    display: flex;
    flex-direction: column;
  }

  .menu-list {
    max-height: inherit;
    flex: 1;
    min-height: 0;
    overflow-y: auto;
    padding: 6px;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: thin;
    scrollbar-color: var(--divider) transparent;
  }

  /* Стилизация скроллбара меню */
  .menu-list::-webkit-scrollbar {
    display: block;
    width: 5px;
  }
  .menu-list::-webkit-scrollbar-thumb {
    background: var(--divider);
    border-radius: 4px;
  }
  .menu-list::-webkit-scrollbar-track {
    background: transparent;
  }

  .menu-item {
    display: flex;
    align-items: center;
    width: 100%;
    box-sizing: border-box;
    padding: 10px 12px;
    background: transparent;
    border: none;
    border-radius: var(--radius-item);
    font-size: 14px;
    font-family: inherit;
    color: var(--text-primary);
    text-align: left;
    transition: background 0.15s ease, color 0.15s ease;
  }

  .menu-item:hover,
  .menu-item.focused {
    background: var(--surface-variant);
  }

  .menu-item.active {
    background: var(--item-selected);
    color: var(--accent);
    font-weight: 600;
  }

  .item-label {
    flex: 1;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  }

  .item-sub {
    font-size: 12px;
    color: var(--text-secondary);
    margin-left: 8px;
  }

  .menu-item.active .item-sub {
    color: var(--accent);
    opacity: 0.8;
  }

  .check {
    margin-left: 8px;
    flex-shrink: 0;
    color: var(--accent);
  }
</style>
