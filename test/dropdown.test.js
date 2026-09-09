import { describe, it, expect } from 'vitest';
import { get } from 'svelte/store';
import { activeDropdownId } from '../src/components/CustomDropdown.svelte';

describe('CustomDropdown activeDropdownId store', () => {
  it('should initialize with null', () => {
    activeDropdownId.set(null);
    expect(get(activeDropdownId)).toBeNull();
  });

  it('should allow only one active dropdown id at a time', () => {
    const id1 = Symbol('dropdown1');
    const id2 = Symbol('dropdown2');

    activeDropdownId.set(id1);
    expect(get(activeDropdownId)).toBe(id1);

    // Opening dropdown 2 overrides dropdown 1
    activeDropdownId.set(id2);
    expect(get(activeDropdownId)).toBe(id2);
    expect(get(activeDropdownId)).not.toBe(id1);

    // Closing drops back to null
    activeDropdownId.set(null);
    expect(get(activeDropdownId)).toBeNull();
  });
});
