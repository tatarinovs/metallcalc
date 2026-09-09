<script>
  import { createEventDispatcher, onMount } from 'svelte';
  import { materialsDb } from '../lib/materialsDb.js';
  import { prefs } from '../lib/prefs.js';
  import CustomDropdown from './CustomDropdown.svelte';

  const dispatch = createEventDispatcher();

  let selectedGroup = null;
  let selectedGrade = null;

  onMount(() => {
    let lastGroupId = prefs.getString('last_group');
    if (!lastGroupId) {
      lastGroupId = 'zinc';
    }

    const group =
      materialsDb.find((g) => g.id === lastGroupId || g.name === lastGroupId) ??
      materialsDb.find((g) => g.id === 'zinc') ??
      materialsDb[0];

    if (group) {
      selectedGroup = group;
      prefs.setString('last_group', group.id);
      const lastGradeName =
        prefs.getString(`last_grade_${group.id}`) ?? prefs.getString(`last_grade_${group.name}`);
      if (lastGradeName) {
        selectedGrade = group.grades.find((g) => g.name === lastGradeName) ?? null;
      }
      if (!selectedGrade && group.grades.length > 0) {
        selectedGrade = group.grades[0];
        prefs.setString(`last_grade_${group.id}`, selectedGrade.name);
      }
    }
    if (selectedGrade) {
      dispatch('change', selectedGrade);
    }
  });

  function selectGroup(groupId) {
    const group = materialsDb.find((g) => g.id === groupId) ?? null;
    if (!group) return;

    prefs.setString('last_group', group.id);

    let prevGrade = null;
    const lastGradeName =
      prefs.getString(`last_grade_${group.id}`) ?? prefs.getString(`last_grade_${group.name}`);
    if (lastGradeName) {
      prevGrade = group.grades.find((g) => g.name === lastGradeName) ?? null;
    }
    if (!prevGrade && group.grades.length > 0) {
      prevGrade = group.grades[0];
      prefs.setString(`last_grade_${group.id}`, prevGrade.name);
    }

    selectedGroup = group;
    selectedGrade = prevGrade;
    dispatch('change', prevGrade);
  }

  function selectGrade(gradeName) {
    const grade = selectedGroup?.grades.find((g) => g.name === gradeName) ?? null;
    if (grade && selectedGroup) {
      prefs.setString(`last_grade_${selectedGroup.id}`, grade.name);
    }
    selectedGrade = grade;
    dispatch('change', grade);
  }

  $: materialOptions = materialsDb.map((g) => ({
    value: g.id,
    label: g.name,
  }));

  $: gradeOptions = selectedGroup
    ? selectedGroup.grades.map((gr) => ({
        value: gr.name,
        label: gr.name,
        sublabel: `${gr.density} г/см³`,
      }))
    : [];
</script>

<div class="selector">
  <CustomDropdown
    label="Материал"
    value={selectedGroup?.id ?? ''}
    options={materialOptions}
    placeholder="Выберите материал"
    on:select={(e) => selectGroup(e.detail)}
  />

  <CustomDropdown
    label="Марка"
    value={selectedGrade?.name ?? ''}
    options={gradeOptions}
    placeholder={selectedGroup ? 'Выберите марку' : 'Сначала выберите материал'}
    disabled={!selectedGroup}
    on:select={(e) => selectGrade(e.detail)}
  />
</div>

<style>
  .selector {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
</style>
