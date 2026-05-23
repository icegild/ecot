> **Extends:** `Node2D`
> Complete health and energy system component for Godot. Attach to any Node2D to add HP/EP management with signals, regeneration, invulnerability frames, and utility methods.

---

## Health Signals

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">health_changed</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>current_health: float</code>, <code>max_health: float</code><br>
Emitted when health value changes.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">health_depleted</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
Emitted when health reaches 0.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">health_increased</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Emitted when health increases.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">health_decreased</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Emitted when health decreases.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">damage_taken</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code>, <code>source: Node</code><br>
Emitted when damage is taken. Includes the source node.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">healed</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Emitted when healing is received.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">max_health_changed</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>new_max_health: float</code><br>
Emitted when maximum health changes.
</p>

---

## Energy Signals

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">energy_changed</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>current_energy: float</code>, <code>max_energy: float</code><br>
Emitted when energy value changes.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">energy_depleted</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
Emitted when energy reaches 0.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">energy_full</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
Emitted when energy reaches maximum.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">energy_increased</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Emitted when energy increases.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">energy_decreased</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Emitted when energy decreases.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">energy_consumed</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Emitted when energy is consumed (ability use).
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">energy_restored</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Emitted when energy is restored.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ffcc00;">max_energy_changed</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>new_max_energy: float</code><br>
Emitted when maximum energy changes.
</p>

---

## Health Exported Variables

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">max_health</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>float</code> | <strong>Default:</strong> <code>100.0</code><br>
Maximum health value. Minimum 1.0. Clamps current health if lowered.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">current_health</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>float</code> | <strong>Default:</strong> <code>100.0</code><br>
Current health value. Clamped between 0 and max_health. Emits signals on change.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">invulnerable</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>bool</code> | <strong>Default:</strong> <code>false</code><br>
When true, all damage is ignored.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">invulnerability_time</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>float</code> | <strong>Default:</strong> <code>1.0</code><br>
Duration of invulnerability after taking damage. Set to 0 to disable.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">start_with_max_health</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>bool</code> | <strong>Default:</strong> <code>true</code><br>
If true, sets current_health to max_health on ready.
</p>

---

## Energy Exported Variables

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">max_energy</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>float</code> | <strong>Default:</strong> <code>100.0</code><br>
Maximum energy value. Minimum 0.0. Clamps current energy if lowered.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">current_energy</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>float</code> | <strong>Default:</strong> <code>100.0</code><br>
Current energy value. Clamped between 0 and max_energy. Emits signals on change.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">energy_regen_enabled</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>bool</code> | <strong>Default:</strong> <code>true</code><br>
Enables automatic energy regeneration.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">energy_regen_rate</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>float</code> | <strong>Default:</strong> <code>5.0</code><br>
Energy restored per second during regeneration.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">energy_regen_delay</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>float</code> | <strong>Default:</strong> <code>2.0</code><br>
Delay in seconds before regeneration starts after energy use.
</p>

<p style="display:block;border-left:4px solid #ffcc00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">start_with_max_energy</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>bool</code> | <strong>Default:</strong> <code>true</code><br>
If true, sets current_energy to max_energy on ready.
</p>

---

## Health Getters

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_health()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns current health value.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_max_health()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns maximum health.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_health_percent()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns health as a fraction between 0.0 and 1.0. Returns 0.0 if max_health is 0.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_health_string()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Returns formatted string like <code>"75 / 100"</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_missing_health()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns missing health amount (max_health - current_health).
</p>

---

## Health Modifiers

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">add_health(amount)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Heals by amount. Does nothing if amount is 0 or negative.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">decrease_health(amount, source = null)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>amount: float</code>, <code>source: Node</code><br>
Damages by amount. Optional source node. Respects invulnerability. Triggers invulnerability frames if enabled.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">take_damage(amount, source = null)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>amount: float</code>, <code>source: Node</code><br>
Alias for <code>decrease_health</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">heal(amount)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Alias for <code>add_health</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">heal_percent(percent)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>percent: float</code><br>
Heals by a percentage of max health. Example: <code>heal_percent(25)</code> heals 25% of max health.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">damage_percent(percent, source = null)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>percent: float</code>, <code>source: Node</code><br>
Damages by a percentage of max health.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_health(value)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>value: float</code><br>
Sets current health directly. Value is clamped automatically.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_max_health(value)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>value: float</code><br>
Sets maximum health. Current health is clamped if needed.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">reset_health()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Restores health to maximum.
</p>

---

## Health Status

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">is_alive()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
Returns <code>true</code> if current_health is greater than 0.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">is_dead()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
Returns <code>true</code> if current_health is 0 or less.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">is_invulnerable()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
Returns <code>true</code> if currently invulnerable.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_invulnerable(value)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>value: bool</code><br>
Manually sets invulnerability state.
</p>

---

## Energy Getters

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_energy()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns current energy value.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_max_energy()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns maximum energy.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_energy_percent()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns energy as a fraction between 0.0 and 1.0. Returns 0.0 if max_energy is 0.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_energy_string()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Returns formatted string like <code>"50 / 100"</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_missing_energy()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">float</span><br>
Returns missing energy amount (max_energy - current_energy).
</p>

---

## Energy Modifiers

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">add_energy(amount)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Restores energy by amount. Does nothing if amount is 0 or negative.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">restore_energy(amount)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Alias for <code>add_energy</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">decrease_energy(amount)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Consumes energy if available. Returns <code>true</code> on success, <code>false</code> if insufficient energy. Resets regen timer.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">consume_energy(amount)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Alias for <code>decrease_energy</code>. Use for ability costs.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">restore_energy_percent(percent)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>percent: float</code><br>
Restores energy by a percentage of max energy.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">consume_energy_percent(percent)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>percent: float</code><br>
Consumes energy by percentage of max. Returns success.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_energy(value)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>value: float</code><br>
Sets current energy directly. Value is clamped automatically.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_max_energy(value)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>value: float</code><br>
Sets maximum energy. Current energy is clamped if needed.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">reset_energy()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Restores energy to maximum.
</p>

---

## Energy Status & Regen

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">has_energy(amount = 1.0)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>amount: float</code><br>
Returns <code>true</code> if current energy is greater than or equal to amount.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">is_energy_full()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
Returns <code>true</code> if energy is at maximum.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">is_energy_empty()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
Returns <code>true</code> if energy is 0 or less.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_energy_regen_enabled(value)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>value: bool</code><br>
Enables or disables automatic energy regeneration. Resets regen timer when disabled.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_energy_regen_rate(rate)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>rate: float</code><br>
Sets the energy regeneration speed in units per second.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_energy_regen_delay(delay)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>delay: float</code><br>
Sets the delay in seconds before regeneration starts after energy use.
</p>

---

## Combined Utilities

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_status_string()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Returns combined status like <code>"HP: 75 / 100 | EP: 50 / 100"</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_status_percent_string()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Returns combined status with percentages like <code>"HP: 75% | EP: 50%"</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">reset_all()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Resets both health and energy to their maximum values.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">is_fully_charged()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
Returns <code>true</code> if both health and energy are at maximum.
</p>