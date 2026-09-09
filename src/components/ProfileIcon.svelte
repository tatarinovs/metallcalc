<script>
  export let type;
  export let color = 'currentColor';
  export let size = 26;
</script>

<svg width={size} height={size} viewBox="0 0 26 26" fill="none" xmlns="http://www.w3.org/2000/svg">
  {#if type === 'sheet'}
    <rect x="4" y="7.5" width="18" height="11.5" stroke={color} stroke-width="1.8" />
    <line x1="4" y1="7.5" x2="2" y2="4.5" stroke={color} stroke-width="1.2" opacity="0.45" />
    <line x1="22" y1="7.5" x2="24" y2="4.5" stroke={color} stroke-width="1.2" opacity="0.45" />
    <line x1="2" y1="4.5" x2="24" y2="4.5" stroke={color} stroke-width="1.2" opacity="0.45" />
  {:else if type === 'square'}
    <rect x="5" y="5" width="16" height="16" stroke={color} stroke-width="1.8" />
  {:else if type === 'circle'}
    <circle cx="13" cy="13" r="11" stroke={color} stroke-width="1.8" />
    <line x1="13" y1="13" x2="22.5" y2="7.5" stroke={color} stroke-width="1.2" opacity="0.45" />
  {:else if type === 'hex'}
    <polygon
      points="23.5,13 18.25,22.1 7.75,22.1 2.5,13 7.75,3.9 18.25,3.9"
      stroke={color}
      stroke-width="1.8"
    />
  {:else if type === 'pipe'}
    <circle cx="13" cy="13" r="11.5" stroke={color} stroke-width="1.8" />
    <circle cx="13" cy="13" r="6.5" stroke={color} stroke-width="1.4" />
  {:else if type === 'pipeSquare'}
    <rect x="1.5" y="1.5" width="23" height="23" stroke={color} stroke-width="1.8" />
    <rect x="5.5" y="5.5" width="15" height="15" stroke={color} stroke-width="1.4" />
  {:else if type === 'pipeRect'}
    <rect x="1" y="4" width="24" height="18" stroke={color} stroke-width="1.8" />
    <rect x="4.5" y="7.5" width="17" height="11" stroke={color} stroke-width="1.4" />
  {:else if type === 'angle'}
    <polyline points="3,3 3,23 23,23" stroke={color} stroke-width="1.8" stroke-linejoin="round" fill="none" />
  {:else if type === 'angleUnequal'}
    <polyline points="3,3 3,23 25,23" stroke={color} stroke-width="1.8" stroke-linejoin="round" fill="none" />
  {:else if type === 'channel'}
    <polyline points="22,3 3,3 3,23 22,23" stroke={color} stroke-width="1.8" stroke-linejoin="round" fill="none" />
  {:else if type === 'ibeam'}
    <line x1="2" y1="3" x2="24" y2="3" stroke={color} stroke-width="1.8" />
    <line x1="13" y1="3" x2="13" y2="23" stroke={color} stroke-width="1.8" />
    <line x1="2" y1="23" x2="24" y2="23" stroke={color} stroke-width="1.8" />
  {:else if type === 'tbeam'}
    <line x1="2" y1="3" x2="24" y2="3" stroke={color} stroke-width="1.8" />
    <line x1="13" y1="3" x2="13" y2="23" stroke={color} stroke-width="1.8" />
  {/if}
</svg>
