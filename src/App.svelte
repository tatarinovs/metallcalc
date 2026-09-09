<script>
  import { onMount, onDestroy } from "svelte";
  import { ProfileType, ALL_PROFILE_TYPES, calcVolume, getFormula } from "./lib/materialData.js";
  import { calculateLinearMassKg } from "./lib/calculator.js";
  import { prefs } from "./lib/prefs.js";

  import ProfileSelector from "./components/ProfileSelector.svelte";
  import DimensionInputs from "./components/DimensionInputs.svelte";
  import MaterialSelector from "./components/MaterialSelector.svelte";
  import ResultDisplay from "./components/ResultDisplay.svelte";

  let profile = ProfileType.sheet;
  let grade = null;
  let dims = [0, 0, 0, 0, 0];

  onMount(() => {
    const savedProfile = prefs.getString("selectedProfile");
    if (savedProfile && ALL_PROFILE_TYPES.includes(savedProfile)) {
      profile = savedProfile;
    }

    // Reveal window smoothly after first frame to avoid white flicker on Windows
    if (typeof window !== "undefined") {
      requestAnimationFrame(() => {
        setTimeout(() => {
          if (window.__TAURI_INTERNALS__) {
            window.__TAURI_INTERNALS__.invoke("show_window").catch(() => {});
          }
        }, 50);
      });
    }
  });

  function onProfileChanged(e) {
    const p = e.detail;
    if (profile === p) return;
    profile = p;
    dims = [0, 0, 0, 0, 0];
    prefs.setString("selectedProfile", p);
  }

  function onGradeChanged(e) {
    grade = e.detail;
  }

  function onDimsChanged(e) {
    dims = e.detail;
  }

  $: volumeMm3 = calcVolume(profile, dims);
  $: linearMassKg = grade
    ? calculateLinearMassKg({
        profile,
        dimensions: dims,
        densityGcm3: grade.density,
      })
    : null;

  // --- Responsive layout: двухколоночный макет зависит от ширины контейнера приложения ---
  let appElement;
  let containerWidth = 0;
  let resizeObserver;

  function updateContainerWidth() {
    if (appElement) {
      containerWidth = appElement.clientWidth;
    }
  }

  onMount(() => {
    updateContainerWidth();
    if (typeof ResizeObserver !== "undefined" && appElement) {
      resizeObserver = new ResizeObserver((entries) => {
        for (const entry of entries) {
          containerWidth = entry.contentRect.width;
        }
      });
      resizeObserver.observe(appElement);
    } else if (typeof window !== "undefined") {
      window.addEventListener("resize", updateContainerWidth);
    }
  });

  onDestroy(() => {
    if (resizeObserver) {
      resizeObserver.disconnect();
    } else if (typeof window !== "undefined") {
      window.removeEventListener("resize", updateContainerWidth);
    }
  });

  $: isWide = (containerWidth || 0) >= 680;
</script>

<div class="app" bind:this={appElement} bind:clientWidth={containerWidth}>
  {#if isWide}
    <div class="wide-layout">
      <div class="col col-left">
        <section class="section">
          <div class="card">
            <ProfileSelector selected={profile} on:change={onProfileChanged} />
          </div>
        </section>

        <section class="section">
          <div class="card">
            <DimensionInputs {profile} on:change={onDimsChanged} />
          </div>
        </section>

        <section class="section">
          <div class="card">
            <MaterialSelector on:change={onGradeChanged} />
          </div>
        </section>
      </div>

      <div class="vdivider" />

      <div class="col col-right">
        <section class="section">
          <ResultDisplay
            {volumeMm3}
            densityGcm3={grade?.density ?? null}
            {linearMassKg}
          />
        </section>

        <section class="section">
          <div class="formula-hint">
            <div class="formula-title">
              <svg
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path
                  d="M18 4H6a2 2 0 00-2 2v12a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2zM9 17H7v-2h2v2zm0-4H7v-2h2v2zm0-4H7V7h2v2zm8 8h-6v-2h6v2zm0-4h-6v-2h6v2zm0-4h-6V7h6v2z"
                />
              </svg>
              <span>Формула расчёта</span>
            </div>
            <pre>{getFormula(profile)}</pre>
            {#if grade}
              <div class="formula-density">ρ = {grade.density} г/см³</div>
            {/if}
          </div>
        </section>
      </div>
    </div>
  {:else}
    <div class="narrow-layout">
      <section class="section">
        <div class="card">
          <ProfileSelector selected={profile} on:change={onProfileChanged} />
        </div>
      </section>

      <section class="section">
        <div class="card">
          <DimensionInputs {profile} on:change={onDimsChanged} />
        </div>
      </section>

      <section class="section">
        <div class="card">
          <MaterialSelector on:change={onGradeChanged} />
        </div>
      </section>

      <section class="section">
        <ResultDisplay
          {volumeMm3}
          densityGcm3={grade?.density ?? null}
          {linearMassKg}
        />
      </section>

      <section class="section">
        <details class="formula-details">
          <summary class="formula-summary">
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="currentColor"
            >
              <path
                d="M18 4H6a2 2 0 00-2 2v12a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2zM9 17H7v-2h2v2zm0-4H7v-2h2v2zm0-4H7V7h2v2zm8 8h-6v-2h6v2zm0-4h-6v-2h6v2zm0-4h-6V7h6v2z"
              />
            </svg>
            <span>Формула расчёта</span>
          </summary>
          <div class="formula-hint">
            <pre>{getFormula(profile)}</pre>
            {#if grade}
              <div class="formula-density">ρ = {grade.density} г/см³</div>
            {/if}
          </div>
        </details>
      </section>
    </div>
  {/if}
</div>

<style>
  .app {
    min-height: auto;
    background: var(--bg);
    color: var(--text-primary);
    padding-top: env(safe-area-inset-top);
    padding-bottom: env(safe-area-inset-bottom);
    padding-left: env(safe-area-inset-left);
    padding-right: env(safe-area-inset-right);
  }

  .narrow-layout {
    padding: 12px 12px 16px;
    max-width: 640px;
    margin: 0 auto;
  }

  .wide-layout {
    display: flex;
    align-items: flex-start;
    max-width: 1200px;
    margin: 0 auto;
  }
  .col {
    flex: 5;
    padding: 16px;
    min-width: 0;
  }
  .col-right {
    flex: 4;
  }
  .vdivider {
    width: 1px;
    background: var(--divider);
    margin: 16px 0;
    align-self: stretch;
  }

  .section {
    margin-bottom: 20px;
  }
  .narrow-layout .section {
    margin-bottom: 16px;
  }
  .card {
    padding: 12px;
    background: var(--surface);
    border: 1px solid var(--divider);
    border-radius: var(--radius-card);
  }

  .formula-hint {
    padding: 14px;
    background: var(--surface-container);
    border: 1px solid var(--divider);
    border-radius: var(--radius-md);
  }
  .formula-title {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.5px;
    color: var(--text-secondary);
  }
  .formula-hint pre {
    margin: 8px 0 0;
    font-family: "SFMono-Regular", Consolas, Menlo, monospace;
    font-size: 13px;
    line-height: 1.5;
    color: var(--text-primary);
    white-space: pre-wrap;
    user-select: text;
    -webkit-user-select: text;
    cursor: text;
  }
  .formula-density {
    margin-top: 6px;
    font-size: 12px;
    font-weight: 500;
    color: var(--accent);
    user-select: text;
    -webkit-user-select: text;
    cursor: text;
  }

  .formula-details {
    background: var(--surface);
    border: 1px solid var(--divider);
    border-radius: var(--radius-md);
    overflow: hidden;
  }
  .formula-summary {
    padding: 10px 14px;
    font-size: 12px;
    font-weight: 600;
    color: var(--text-secondary);
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    user-select: none;
  }
  .formula-summary:hover {
    color: var(--text-primary);
  }
  .formula-details[open] .formula-summary {
    border-bottom: 1px solid var(--divider);
  }
  .formula-details .formula-hint {
    border: none;
    border-radius: 0;
    padding: 10px 14px;
  }
</style>
