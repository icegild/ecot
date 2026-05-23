> A Godot game project featuring modular component-based architecture with dynamic character skins, health/energy systems, and smooth platformer mechanics.

---

## GitHub

<p style="display:block;border-left:4px solid #667eea;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">Open Repository</strong><br>
Explore the source code, report issues, or contribute to the project.<br><br>
<a href="https://github.com/icegild/ecot" style="display:inline-block;background:#667eea;color:#fff;padding:0.5rem 1.5rem;border-radius:8px;text-decoration:none;font-weight:bold;">github.com/icegild/ecot</a>
</p>

---

## Component Documentation

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">Health & Energy Component</strong><br>
Complete HP/EP system with signals, regeneration, invulnerability frames, and utility methods.<br><br>
<a href="obsidian://open?file=HealthAndEnergyComponent" style="display:inline-block;background:#ff3333;color:#fff;padding:0.4rem 1rem;border-radius:6px;text-decoration:none;">View Documentation</a>
</p>

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">Character Animation Component</strong><br>
Dynamic skin switching system with 8 built-in character themes and full animation control.<br><br>
<a href="obsidian://open?file=CharacterAnimationComponent" style="display:inline-block;background:#ffaa00;color:#000;padding:0.4rem 1rem;border-radius:6px;text-decoration:none;">View Documentation</a>
</p>

---

## Project Structure

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">File Layout</strong><br>
<code>res://</code><br>
<code>├── animations/</code> &nbsp; <em>SpriteFrames resources (blood.tres, dark.tres, etc.)</em><br>
<code>├── assets/</code> &nbsp; <em>Game assets</em><br>
<code>│&nbsp;&nbsp; └── player/</code> &nbsp; <em>8 character themes (blood, dark, electricity, fairy, moon, shell, time, vine)</em><br>
<code>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ├── attack/</code><br>
<code>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ├── idle/</code><br>
<code>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; └── walk/</code><br>
<code>├── prefabs/</code> &nbsp; <em>Reusable scene templates</em><br>
<code>├── scenes/</code> &nbsp; <em>Game scenes</em><br>
<code>├── scripts/</code> &nbsp; <em>GDScript files</em><br>
<code>└── vault/</code> &nbsp; <em>Obsidian documentation vault</em>
</p>

<p style="display:none;">[[CharacterAnimationComponent]] [[HealthAndEnergyComponent]]</p>



---

## Related Files

- [[CharacterAnimationComponent]]
- [[HealthAndEnergyComponent]]
- [[TODO]]