<script>
  import { createEventDispatcher } from 'svelte';
  import { fly } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';
  import { ProfileType, getLabel } from '../lib/materialData.js';
  import ProfileIcon from './ProfileIcon.svelte';

  export let selected;

  const dispatch = createEventDispatcher();

  const mainProfiles = [ProfileType.sheet];
  const barOptions = [ProfileType.circle, ProfileType.hex, ProfileType.square];
  const pipeOptions = [ProfileType.pipe, ProfileType.pipeSquare, ProfileType.pipeRect];
  const structuralOptions = [
    ProfileType.angle,
    ProfileType.angleUnequal,
    ProfileType.channel,
    ProfileType.ibeam,
    ProfileType.tbeam,
  ];

  let openMenu = null; // 'bar' | 'pipe' | 'structural' | null

  function select(p) {
    dispatch('change', p);
    openMenu = null;
  }

  function toggleMenu(name) {
    openMenu = openMenu === name ? null : name;
  }

  function closeMenus() {
    openMenu = null;
  }

  let lastSelected = {
    bar: barOptions[0],
    pipe: pipeOptions[0],
    structural: structuralOptions[0],
  };

  $: if (barOptions.includes(selected)) lastSelected.bar = selected;
  $: if (pipeOptions.includes(selected)) lastSelected.pipe = selected;
  $: if (structuralOptions.includes(selected)) lastSelected.structural = selected;

  function groupInfo(options, currentSelected, groupName) {
    const isActive = options.includes(currentSelected);
    const displayType = isActive ? currentSelected : (lastSelected[groupName] || options[0]);
    return { isActive, displayType };
  }

  function onKeyDown(e) {
    if (e.key === 'Escape' && openMenu != null) {
      openMenu = null;
    }
  }
</script>

<svelte:window on:click={closeMenus} on:keydown={onKeyDown} />

<div class="profile-row">
  {#each mainProfiles as p}
    <button
      type="button"
      class="profile-btn"
      class:selected={selected === p}
      on:click|stopPropagation={() => select(p)}
    >
      <ProfileIcon type={p} color={selected === p ? 'var(--accent)' : 'var(--text-secondary)'} />
      <span>{getLabel(p)}</span>
    </button>
  {/each}

  {#each [
    { name: 'bar', label: 'Пруток', options: barOptions },
    { name: 'pipe', label: 'Труба', options: pipeOptions },
    { name: 'structural', label: 'Фасонный', options: structuralOptions },
  ] as group, groupIdx}
    {@const info = groupInfo(group.options, selected, group.name)}
    <div class="profile-group">
      <button
        type="button"
        class="profile-btn"
        class:selected={info.isActive}
        on:click|stopPropagation={() => toggleMenu(group.name)}
      >
        <ProfileIcon
          type={info.displayType}
          color={info.isActive ? 'var(--accent)' : 'var(--text-secondary)'}
        />
        <span>{group.label}</span>
        <svg
          class="caret"
          class:open={openMenu === group.name}
          width="11"
          height="11"
          viewBox="0 0 24 24"
          fill="currentColor"
        >
          <path d="M7 10l5 5 5-5z" />
        </svg>
      </button>
      {#if openMenu === group.name}
        <!-- svelte-ignore a11y-click-events-have-key-events a11y-no-noninteractive-element-interactions -->
        <div
          class="dropdown"
          role="menu"
          tabindex="-1"
          class:align-right={groupIdx >= 1}
          transition:fly={{ y: -8, duration: 200, easing: cubicOut }}
          on:click|stopPropagation
        >
          {#each group.options as p}
            <button
              type="button"
              class="dropdown-item"
              class:selected={selected === p}
              on:click={() => select(p)}
            >
              <ProfileIcon
                type={p}
                size={22}
                color={selected === p ? 'var(--accent)' : 'var(--text-secondary)'}
              />
              <span>{getLabel(p)}</span>
              {#if selected === p}
                <svg class="check" width="16" height="16" viewBox="0 0 24 24" fill="var(--accent)">
                  <path d="M9 16.2l-3.5-3.5L4 14.2 9 19.2 20 8.2l-1.5-1.5z" />
                </svg>
              {/if}
            </button>
          {/each}
        </div>
      {/if}
    </div>
  {/each}
</div>

<style>
  .profile-row {
    display: flex;
    gap: 8px;
    height: 68px;
  }
  .profile-group {
    position: relative;
    flex: 1;
    height: 100%;
    min-width: 0;
  }
  .profile-btn {
    flex: 1;
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 5px;
    background: var(--surface-variant);
    border: 1px solid var(--divider);
    border-radius: 12px;
    cursor: pointer;
    padding: 6px 4px;
    position: relative;
    transition: background 0.2s ease, border-color 0.2s ease, transform 0.12s ease;
    font: inherit;
    user-select: none;
  }
  .profile-btn:hover {
    background: color-mix(in srgb, var(--accent) 8%, var(--surface-variant));
  }
  .profile-btn:active {
    transform: scale(0.96);
  }
  .profile-btn.selected {
    background: color-mix(in srgb, var(--accent) 15%, transparent);
    border-color: var(--accent);
    border-width: 1.5px;
  }
  .profile-btn span {
    font-size: 11px;
    color: var(--text-secondary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100%;
    transition: color 0.15s ease;
  }
  .profile-btn.selected span {
    color: var(--accent);
    font-weight: 600;
  }
  .profile-btn .caret {
    position: absolute;
    bottom: 3px;
    right: 3px;
    opacity: 0.75;
    color: var(--text-secondary);
    transition: transform 0.22s cubic-bezier(0.34, 1.56, 0.64, 1), color 0.15s ease;
  }
  .profile-btn .caret.open {
    transform: rotate(180deg);
  }
  .profile-btn.selected .caret {
    color: var(--accent);
  }
  .dropdown {
    position: absolute;
    top: calc(100% + 6px);
    left: 0;
    min-width: 220px;
    background: var(--surface);
    border: 1px solid var(--divider);
    border-radius: 14px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
    padding: 6px;
    z-index: 20;
    backdrop-filter: blur(10px);
  }
  .dropdown.align-right,
  .profile-group:last-child .dropdown {
    left: auto;
    right: 0;
  }
  .dropdown-item {
    display: flex;
    align-items: center;
    gap: 10px;
    width: 100%;
    padding: 10px 12px;
    margin: 2px 0;
    background: transparent;
    border: 1.2px solid transparent;
    border-radius: 10px;
    cursor: pointer;
    text-align: left;
    font: inherit;
    transition: background 0.15s ease, border-color 0.15s ease, transform 0.1s ease;
  }
  .dropdown-item:hover {
    background: var(--surface-variant);
  }
  .dropdown-item:active {
    transform: scale(0.98);
  }
  .dropdown-item span {
    font-size: 13px;
    color: var(--text-primary);
    flex: 1;
    transition: color 0.15s ease;
  }
  .dropdown-item.selected {
    background: color-mix(in srgb, var(--accent) 15%, transparent);
    border-color: var(--accent);
  }
  .dropdown-item.selected span {
    color: var(--accent);
    font-weight: 600;
  }
  .check {
    flex-shrink: 0;
  }
</style>
