> **Extends:** `Node2D`
> Dynamic character skin switching system for Godot. Manages 8 built-in character themes with full animation control, resource management, and signals.

---

## Signals

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">character_changed</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>character_name: String</code>, <code>previous_character: String</code><br>
Emitted when the active character is switched.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">animations_switched</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>character_name: String</code><br>
Emitted when animations are successfully applied to the sprite.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">animation_played</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>animation_name: String</code><br>
Emitted whenever an animation starts playing.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">character_order_changed</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>new_order: Array</code><br>
Emitted when the character order array is modified.
</p>

<p style="display:block;border-left:4px solid #ff3333;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;color:#ff3333;">animation_resources_loaded</strong> <span style="background:#ff3333;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">SIGNAL</span><br>
<strong>Parameters:</strong> <code>loaded_characters: Array</code><br>
Emitted when all animation resources finish loading.
</p>

---

## Exported Variables

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">animated_sprite</strong> <span style="background:#ffaa00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>AnimatedSprite2D</code> | <strong>Default:</strong> <code>null</code><br>
Sprite node to control. Auto-detected if empty.
</p>

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">current_character</strong> <span style="background:#ffaa00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>String</code> | <strong>Default:</strong> <code>"blood"</code><br>
Currently active character name.
</p>

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">character_order</strong> <span style="background:#ffaa00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>Array</code> | <strong>Default:</strong> <code>["blood","dark","electricity","fairy","moon","shell","time","vine"]</code><br>
Order of characters for cycling.
</p>

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">auto_play_idle</strong> <span style="background:#ffaa00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>bool</code> | <strong>Default:</strong> <code>true</code><br>
Auto-play default animation on character switch.
</p>

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">default_animation</strong> <span style="background:#ffaa00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>String</code> | <strong>Default:</strong> <code>"idle"</code><br>
Default animation to play when switching characters.
</p>

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">animation_resource_dir</strong> <span style="background:#ffaa00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>String</code> | <strong>Default:</strong> <code>"res://animations/"</code><br>
Directory containing animation resource files.
</p>

<p style="display:block;border-left:4px solid #ffaa00;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">animation_file_extension</strong> <span style="background:#ffaa00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">EXPORT</span><br>
<strong>Type:</strong> <code>String</code> | <strong>Default:</strong> <code>".tres"</code><br>
File extension for animation resources.
</p>

---

## Initialization & Resource Management

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">load_all_animations()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Loads all animation resources from <code>character_order</code> array. Emits <code>animation_resources_loaded</code> when complete.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">load_character_animation(character_name)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>character_name: String</code><br>
Loads a specific character's animation resource from disk.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">reload_animations()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Clears all cached animations and reloads them from disk.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">unload_character_animation(character_name)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>character_name: String</code><br>
Unloads a specific character's animation resource to free memory. Won't unload the currently active character.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">unload_unused_animations()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Unloads all animation resources except the currently active one. Use to optimize memory.
</p>

---

## Character Switching

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">switch_to_character(character_name)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>character_name: String</code><br>
Switches to a specific character by name. Returns <code>false</code> if the character doesn't exist.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">switch_to_next_character()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Switches to the next character in the order. Wraps around to the first when reaching the end.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">switch_to_previous_character()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Switches to the previous character in the order. Wraps around to the last when at the beginning.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">switch_to_random_character()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Switches to a randomly selected character from the available ones.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">switch_to_character_by_index(index)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>index: int</code><br>
Switches to a character by its index in the <code>character_order</code> array.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">switch_animations(character_name)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>character_name: String</code><br>
<strong>Internal.</strong> Switches the animation resource and updates the sprite frames.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">update_animation_frames()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Applies the current animation resource to the sprite and plays the default animation.
</p>

---

## Animation Control

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">play_animation(animation_name)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>animation_name: String</code><br>
Plays a specific animation by name. Emits the <code>animation_played</code> signal.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">stop_animation()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Stops the currently playing animation.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">pause_animation()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Pauses the currently playing animation.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_available_animations()</strong> <span style="background:#cc66ff;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">Array[String]</span><br>
Returns a list of all animation names available for the current character.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">has_animation(animation_name)</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<strong>Parameters:</strong> <code>animation_name: String</code><br>
Checks if the current character has a specific animation.
</p>

---

## Getters

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_current_character()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Name of the currently active character.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_current_character_index()</strong> <span style="background:#66ccff;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">int</span><br>
Index in <code>character_order</code>. Returns <code>-1</code> if not found.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_character_count()</strong> <span style="background:#66ccff;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">int</span><br>
Total number of characters in the order.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_loaded_animation_count()</strong> <span style="background:#66ccff;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">int</span><br>
Number of characters with loaded animation resources.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">can_switch_characters()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<code>true</code> if there's more than one character available.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_current_animation_resource()</strong> <span style="background:#cc66ff;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">Resource</span><br>
The current <code>SpriteFrames</code> resource.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_animated_sprite()</strong> <span style="background:#cc66ff;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">AnimatedSprite2D</span><br>
Reference to the controlled sprite node.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_current_animation_name()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Name of the currently playing animation.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">is_playing()</strong> <span style="background:#ffcc00;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">bool</span><br>
<code>true</code> if an animation is currently playing.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_current_frame()</strong> <span style="background:#66ccff;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">int</span><br>
Current frame number of the animation.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_loaded_characters()</strong> <span style="background:#cc66ff;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">Array[String]</span><br>
All characters with successfully loaded resources.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_character_order()</strong> <span style="background:#cc66ff;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">Array[String]</span><br>
A copy of the character order array.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_next_character_name()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Next character name without switching.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_previous_character_name()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Previous character name without switching.
</p>

---

## Setters

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_animated_sprite(sprite)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>sprite: AnimatedSprite2D</code><br>
Sets the <code>AnimatedSprite2D</code> node to control.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_animation_resource_dir(dir)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>dir: String</code><br>
Sets the directory path for animation resources. Appends <code>/</code> if missing.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_animation_file_extension(ext)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>ext: String</code><br>
Sets the animation file extension. Prepends <code>.</code> if missing.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_default_animation(animation_name)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>animation_name: String</code><br>
Sets the default animation to play when switching characters.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">set_auto_play_idle(enabled)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>enabled: bool</code><br>
Toggles auto-playing the default animation on character switch.
</p>

---

## Utility Methods

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">add_character(character_name, load_now = true)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>character_name: String</code>, <code>load_now: bool</code><br>
Adds a new character to the order and optionally loads its animation.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">remove_character(character_name, unload_now = true)</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
<strong>Parameters:</strong> <code>character_name: String</code>, <code>unload_now: bool</code><br>
Removes a character from the order. Switches to another first if removing the current one.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">shuffle_character_order()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Randomly shuffles the <code>character_order</code> array. Emits <code>character_order_changed</code>.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">reset()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Resets the component to initial state. Stops animation and switches to the first character.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">get_state_string()</strong> <span style="background:#ff9999;color:#000;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">String</span><br>
Returns a formatted string representation of the current component state.
</p>

<p style="display:block;border-left:4px solid #66ccff;padding:0.5rem 1rem;margin:0.5rem 0;">
<strong style="font-size:1.2rem;">print_state()</strong> <span style="background:#666;color:#fff;padding:0.15rem 0.5rem;border-radius:10px;font-size:0.75rem;">void</span><br>
Prints the current component state to the Godot console.
</p>