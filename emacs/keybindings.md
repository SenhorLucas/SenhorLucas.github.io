Default keybindings
===================

This is the beginning of my journey on setting my personal keybinding set in
order to optimize my workflow. I'll take default keybindings from Vim, Tmux and
Regolith as starting point.

Vim
---

Step by step to get  where I want:

- The most used commands are easily accessible
- No wild changes to defaults
- Focus on insert mode bindings
- In command mode:
  1. Check which keys are free
  2. Check which keys are bound to commands that I don't use
  3. Identify most used commands

Most accessible characters - the home row
-----------------------------------------

tag		char	      note action in Normal mode	~
------------------------------------------------------------------------------
|a|		a		2  append text after the cursor N times
|s|		["x]s		2  (substitute) delete N characters [into
				   register x] and start insert
|d|		["x]d{motion}	2  delete Nmove text [into register x]
|dd|		["x]dd		2  delete N lines [into register x]
|do|		do		2  same as ":diffget"
|dp|		dp		2  same as ":diffput"
|f|		f{char}		1  cursor to Nth occurrence of {char} to the
				   right
|g|		g{char}		   extended commands, see |g| below
|h|		h		1  cursor N chars to the left
|j|		j		1  cursor N lines downward
|k|		k		1  cursor N lines upward
|l|		l		1  cursor N chars to the right
|:|		:		1  start entering an Ex command
|N:|		{count}:	   start entering an Ex command with range
				   from current line to N-1 lines down
|'|		'{a-zA-Z0-9}	1  cursor to the first CHAR on the line with
|z|		z{char}		   commands starting with 'z', see |z| below
				   mark {a-zA-Z0-9}. See jumps
|x|		["x]x		2  delete N characters under and after the
				   cursor [into register x]
|c|		["x]c{motion}	2  delete Nmove text [into register x] and
				   start insert
|cc|		["x]cc		2  delete N lines [into register x] and start
				   insert
|v|		v		   start characterwise Visual mode
|b|		b		1  cursor N words backward
|n|		n		1  repeat the latest '/' or '?' N times
|m|		m{A-Za-z}	   set mark {A-Za-z} at cursor position
|,|		,		1  repeat latest f, t, F or T in opposite
				   direction N times
|.|		.		2  repeat last change with count replaced with
				   N
|/|		/{pattern}<CR>	1  search forward for the Nth occurrence of
				   {pattern}
|/<CR>|		/<CR>		1  search forward for {pattern} of last search
|q|		q{0-9a-zA-Z"}	   record typed characters into named register
				   {0-9a-zA-Z"} (uppercase to append)
|q|		q		   (while recording) stops recording
|q:|		q:		   edit : command-line in command-line window
|q/|		q/		   edit / command-line in command-line window
|q?|		q?		   edit ? command-line in command-line window
|w|		w		1  cursor N words forward
|e|		e		1  cursor forward to the end of word N
|r|		r{char}		2  replace N chars with {char}
|t|		t{char}		1  cursor till before Nth occurrence of {char}
				   to the right
|y|		["x]y{motion}	   yank Nmove text [into register x]
|yy|		["x]yy		   yank N lines [into register x]
|u|		u		2  undo changes
|o|		o		2  begin a new line below the cursor and
|i|		i		2  insert text before the cursor N times
				   insert text, repeat N times
|p|		["x]p		2  put the text [from register x] after the
				   cursor N times
|[|		[{char}		   square bracket command (see |[| below)
		\		   not used
|]|		]{char}		   square bracket command (see |]| below)


Shift characters
----------------

|A|		A		2  append text after the end of the line N times
|S|		["x]S		2  delete N lines [into register x] and start
				   insert; synonym for "cc".
|D|		["x]D		2  delete the characters under the cursor
				   until the end of the line and N-1 more
				   lines [into register x]; synonym for "d$"
|F|		F{char}		1  cursor to the Nth occurrence of {char} to
				   the left
|G|		G		1  cursor to line N, default last line
|H|		H		1  cursor to line N from top of screen
|J|		J		2  Join N lines; default is 2
|K|		K		   lookup Keyword under the cursor with
				   'keywordprg'
|L|		L		1  cursor to line N from bottom of screen
|;|		;		1  repeat latest f, t, F or T N times
|quote|		"{register}  	   use {register} for next delete, yank or put
				   ({.%#:} only work with put)
|bar|		|		1  cursor to column N
|Z|		Z		0  FREE
|ZZ|		ZZ		   write if buffer changed and close window
|ZQ|		ZQ		   close window without writing
|X|		["x]X		2  delete N characters before the cursor [into
				   register x]
|C|		["x]C		2  change from the cursor position to the end
				   of the line, and N-1 more lines [into
				   register x]; synonym for "c$"
|V|		V		   start linewise Visual mode
|B|		B		1  cursor N WORDS backward
|N|		N		1  repeat the latest '/' or '?' N times in
|M|		M		1  cursor to middle line of screen
				   opposite direction
|<|		<{motion}	2  shift Nmove lines one 'shiftwidth'
				   leftwards
|<<|		<<		2  shift N lines one 'shiftwidth' leftwards
|>|		>{motion}	2  shift Nmove lines one 'shiftwidth'
				   rightwards
|>>|		>>		2  shift N lines one 'shiftwidth' rightwards
|?|		?{pattern}<CR>	1  search backward for the Nth previous
				   occurrence of {pattern}
|?<CR>|		?<CR>		1  search backward for {pattern} of last search
|Q|		Q		   switch to "Ex" mode
|W|		W		1  cursor N WORDS forward
|E|		E		1  cursor forward to the end of WORD N
|R|		R		2  enter replace mode: overtype existing
				   characters, repeat the entered text N-1
				   times
|T|		T{char}		1  cursor till after Nth occurrence of {char}
				   to the left
|Y|		["x]Y		   yank N lines [into register x]; synonym for
				   "yy"
|U|		U		2  undo all latest changes on one line
|I|		I		2  insert text before the first CHAR on the
				   line N times
|O|		O		2  begin a new line above the cursor and
				   insert text, repeat N times
|P|		["x]P		2  put the text [from register x] before the
				   cursor N times
|{|		{		1  cursor N paragraphs backward
|}|		}		1  cursor N paragraphs forward

|~|		~		2  'tildeop' off: switch case of N characters
				   under cursor and move the cursor N
				   characters to the right
|~|		~{motion}	   'tildeop' on: switch case of Nmove text
		CTRL-@		   not used

Other characters
----------------
|<BS>|		<BS>		1  same as "h"
|<Tab>|		<Tab>		1  go to N newer entry in jump list
|<CR>|		<CR>		1  cursor to the first CHAR N lines lower
|<NL>|		<NL>		1  same as "j"
|<Space>|	<Space>		1  same as "l"

Control characters
------------------
|CTRL-A|	CTRL-A		2  add N to number at/after cursor
|CTRL-S|	CTRL-S		   FREE
|CTRL-D|	CTRL-D		   scroll Down N lines (default: half a screen)
|CTRL-F|	CTRL-F		1  scroll N screens Forward
|CTRL-G|	CTRL-G		   display current file name and position
|CTRL-H|	CTRL-H		1  FREE
|CTRL-J|	CTRL-J		1  FREE
		CTRL-K		   FREE
|CTRL-K|	CTRL-K		   FREE
|CTRL-L|	CTRL-L		   redraw screen
|CTRL-:|	CTRL-:		   FREE
|CTRL-'|	CTRL-'		   FREE
|CTRL-\|	CTRL-\		   FREE / leader - remap that to SPACE!
|CTRL-Z|	CTRL-Z		   suspend program (or start new shell)
|CTRL-X|	CTRL-X		2  subtract N from number at/after cursor
|CTRL-C|	CTRL-C		   interrupt current (search) command
|CTRL-V|	CTRL-V		   start blockwise Visual mode
|CTRL-B|	CTRL-B		1  scroll N screens Backwards
|CTRL-N|	CTRL-N		1  FREE
|CTRL-M|	CTRL-M		1  FREE
|CTRL-,|	CTRL-,		   FREE
|CTRL-.|	CTRL-.		   FREE
|CTRL-/|	CTRL-/		   FREE
|CTRL-Q|	CTRL-Q		1  FREE
		CTRL-Q		   FREE
|CTRL-W|	CTRL-W {char}	   window commands, see |CTRL-W|
|CTRL-E|	CTRL-E		   scroll N lines upwards (N lines Extra)
|CTRL-R|	CTRL-R		2  redo changes which were undone with 'u'
		CTRL-S		   FREE
|CTRL-T|	CTRL-T		   jump to N older Tag in tag list
|CTRL-Y|	CTRL-Y		   scroll N lines downwards
|CTRL-U|	CTRL-U		   scroll N lines Upwards (default: half a
				   screen)
|CTRL-I|	CTRL-I		1  FREE
|CTRL-O|	CTRL-O		1  go to N older entry in jump list
|CTRL-P|	CTRL-P		1  FREE / Find file
|CTRL-[|	CTRL-[		   FREE
|CTRL-]|	CTRL-]		   :ta to ident under cursor

|CTRL-^|	CTRL-^		   edit Nth alternate file (equivalent to
				   ":e #N")
		CTRL-_		   not used

Number row
----------
|0|		0		1  cursor to the first char of the line
|-|		-		1  cursor to the first CHAR N lines higher
|=|		={motion}	2  filter Nmove lines through "indent"
|==|		==		2  filter N lines through "indent"

|!|		!{motion}{filter}
				2  filter Nmove text through the {filter}
				   command
|!!|		!!{filter}	2  filter N lines through the {filter} command
|@|		@{a-z}		2  execute the contents of register {a-z}
				   N times
|@:|		@:		   repeat the previous ":" command N times
|@@|		@@		2  repeat the previous @{a-z} N times
|#|		#		1  search backward for the Nth occurrence of
				   the ident under the cursor
|$|		$		1  cursor to the end of Nth next line
|%|		%		1  find the next (curly/square) bracket on
				   this line and go to its match, or go to
				   matching comment bracket, or go to matching
				   preprocessor directive.
|N%|		{count}%	1  go to N percentage in the file
|^|		^		1  cursor to the first CHAR of the line
|&|		&		2  repeat last :s
|star|		*		1  search forward for the Nth occurrence of
|(|		(		1  cursor N sentences backward
|)|		)		1  cursor N sentences forward
				   the ident under the cursor
|+|		+		1  FREE
|_|		_		1  cursor to the first CHAR N - 1 lines lower


Jumps
-----
|'|		'{a-zA-Z0-9}	1  cursor to the first CHAR on the line with
				   mark {a-zA-Z0-9}
|''|		''		1  cursor to the first CHAR of the line where
				   the cursor was before the latest jump.
|'(|		'(		1  cursor to the first CHAR on the line of the
				   start of the current sentence
|')|		')		1  cursor to the first CHAR on the line of the
				   end of the current sentence
|'<|		'<		1  cursor to the first CHAR of the line where
				   highlighted area starts/started in the
				   current buffer.
|'>|		'>		1  cursor to the first CHAR of the line where
				   highlighted area ends/ended in the current
				   buffer.
|'[|		'[		1  cursor to the first CHAR on the line of the
				   start of last operated text or start of put
				   text
|']|		']		1  cursor to the first CHAR on the line of the
				   end of last operated text or end of put
				   text
|'{|		'{		1  cursor to the first CHAR on the line of the
				   start of the current paragraph
|'}|		'}		1  cursor to the first CHAR on the line of the
				   end of the current paragraph


Marks
-----

|`|		`{a-zA-Z0-9}	1  cursor to the mark {a-zA-Z0-9}
|`(|		`(		1  cursor to the start of the current sentence
|`)|		`)		1  cursor to the end of the current sentence
|`<|		`<		1  cursor to the start of the highlighted area
|`>|		`>		1  cursor to the end of the highlighted area
|`[|		`[		1  cursor to the start of last operated text
				   or start of putted text
|`]|		`]		1  cursor to the end of last operated text or
				   end of putted text
|``|		``		1  cursor to the position before latest jump
|`{|		`{		1  cursor to the start of the current paragraph
|`}|		\`}		1  cursor to the end of the current paragraph


Other keys
----------

|<C-End>|	<C-End>		1  same as "G"
|<C-Home>|	<C-Home>	1  same as "gg"
|<C-Left>|	<C-Left>	1  same as "b"
|<C-LeftMouse>|	<C-LeftMouse>	   ":ta" to the keyword at the mouse click
|<C-Right>|	<C-Right>	1  same as "w"
|<C-RightMouse>| <C-RightMouse>	   same as "CTRL-T"
|<C-Tab>|	<C-Tab>		   same as "g<Tab>"
|<Del>|		["x]<Del>	2  same as "x"
|N<Del>|	{count}<Del>	   remove the last digit from {count}
|<End>|		<End>		1  same as "$"
|<F1>|		<F1>		   same as <Help>
|<Help>|	<Help>		   open a help window
|<Home>|	<Home>		1  same as "0"
|<Insert>|	<Insert>	2  same as "i"
|<PageDown>|	<PageDown>	   same as CTRL-F
|<PageUp>|	<PageUp>	   same as CTRL-B
|<S-Down>|	<S-Down>	1  same as CTRL-F
|<S-Left>|	<S-Left>	1  same as "b"
|<S-LeftMouse>|	<S-LeftMouse>	   same as "*" at the mouse click position
|<S-Right>|	<S-Right>	1  same as "w"
|<S-RightMouse>| <S-RightMouse>	   same as "#" at the mouse click position
|<S-Up>|	<S-Up>		1  same as CTRL-B
|<Undo>|	<Undo>		2  same as "u"


Strange
-------
|CTRL-\_CTRL-N|	CTRL-\ CTRL-N	   go to Normal mode (no-op)
|CTRL-\_CTRL-G|	CTRL-\ CTRL-G	   go to mode specified with 'insertmode'
		CTRL-\ a - z	   reserved for extensions
		CTRL-\ others      not used


Insert mode
===========

tag		char		action in Insert mode	~
-----------------------------------------------------------------------
|i_CTRL-A|	CTRL-A			insert previously inserted text
		CTRL-S			FREE not used or used for terminal control flow
|i_CTRL-D|	CTRL-D			delete one shiftwidth of indent in the current
					line
		CTRL-F			FREE not used (but by default it's in 'cinkeys' to
					re-indent the current line)
		CTRL-G			FREE
|i_CTRL-H|	CTRL-H			FREE same as <BS>
|i_CTRL-J|	CTRL-J			FREE same as <CR>
|i_CTRL-K|	CTRL-K {char1} {char2}	enter digraph
|i_CTRL-L|	CTRL-L			when 'insertmode' set: Leave Insert mode
		CTRL-:			FREE
		CTRL-'			FREE
		CTRL-\			FREE
|i_CTRL-Z|	CTRL-Z			when 'insertmode' set: suspend Vim
|i_CTRL-X|	CTRL-X {mode}		enter CTRL-X sub mode, see |i_CTRL-X_index|
|i_CTRL-C|	CTRL-C			quit insert mode, without checking for
					abbreviation, unless 'insertmode' set.
|i_CTRL-V|	CTRL-V {char}		insert next non-digit literally
		CTRL-B			FREE
|i_CTRL-N|	CTRL-N			find next match for keyword in front of the
|i_CTRL-M|	CTRL-M			same as <CR>
		CTRL-,			FREE
		CTRL-.			FREE
		CTRL-/			FREE
|i_CTRL-Q|	CTRL-Q			FREE same as CTRL-V, unless used for terminal
					control flow
|i_CTRL-W|	CTRL-W			delete word before the cursor
|i_CTRL-E|	CTRL-E			insert the character which is below the cursor
|i_CTRL-R|	CTRL-R {register}	insert the contents of a register
|i_CTRL-R_CTRL-R| CTRL-R CTRL-R {register}	 insert the contents of a register literally
|i_CTRL-R_CTRL-O| CTRL-R CTRL-O {register}	insert the contents of a register literally
						and don't auto-indent
|i_CTRL-R_CTRL-P| CTRL-R CTRL-P {register} 	insert the contents of a register literally
						and fix indent.
|i_CTRL-T|	CTRL-T			insert one shiftwidth of indent in current
					line
|i_CTRL-Y|	CTRL-Y			FREE insert the character which is above the cursor
|i_CTRL-U|	CTRL-U			delete all entered characters in the current
					line
|i_CTRL-I|	CTRL-I			FREE same as <Tab>
|i_CTRL-O|	CTRL-O			execute a single command and return to insert
					mode
|i_CTRL-P|	CTRL-P			find previous match for keyword in front of
					the cursor
		CTRL-[			FREE
		CTRL-]			FREE

|i_digraph|	{char1}<BS>{char2}	enter digraph (only when 'digraph' option set)
					cursor


|i_CTRL-SHIFT-Q|  CTRL-SHIFT-Q {char}	like CTRL-Q unless |modifyOtherKeys| is active
|i_CTRL-SHIFT-V|  CTRL-SHIFT-V {char} 	like CTRL-V unless |modifyOtherKeys| is active
|i_CTRL-V_digit| CTRL-V {number} 	insert three digit decimal number as a single
					byte.
|i_<Esc>|	<Esc>			end insert mode (unless 'insertmode' set)
|i_CTRL-[|	CTRL-[			same as <Esc>
|i_CTRL-]|	CTRL-]			trigger abbreviation
|i_CTRL-^|	CTRL-^			toggle use of |:lmap| mappings
|i_CTRL-_|	CTRL-_			When 'allowrevins' set: change language
					(Hebrew, Farsi) {only when compiled with
					the |+rightleft| feature}

|i_CTRL-@|	CTRL-@			insert previously inserted text and stop
					insert


|i_CTRL-G_j|	CTRL-G CTRL-J		line down, to column where inserting started
|i_CTRL-G_j|	CTRL-G j		line down, to column where inserting started
|i_CTRL-G_j|	CTRL-G <Down>		line down, to column where inserting started
|i_CTRL-G_k|	CTRL-G CTRL-K		line up, to column where inserting started
|i_CTRL-G_k|	CTRL-G k		line up, to column where inserting started
|i_CTRL-G_k|	CTRL-G <Up>		line up, to column where inserting started
|i_CTRL-G_u|	CTRL-G u		start new undoable edit
|i_CTRL-G_U|	CTRL-G U		don't break undo with next cursor movement

|i_CTRL-\_CTRL-N| CTRL-\ CTRL-N		go to Normal mode
|i_CTRL-\_CTRL-G| CTRL-\ CTRL-G		go to mode specified with 'insertmode'
		CTRL-\ a - z		reserved for extensions
		CTRL-\ others		not used
		<Space> to '~'	not used, except '0' and '^' followed by
				CTRL-D

|i_0_CTRL-D|	0 CTRL-D	delete all indent in the current line
|i_^_CTRL-D|	^ CTRL-D	delete all indent in the current line, restore
				it in the next line

|i_<Del>|	<Del>		delete character under the cursor

		Meta characters (0x80 to 0xff, 128 to 255)
				not used


commands in CTRL-X submode				*i_CTRL-X_index*

|i_CTRL-X_CTRL-D|	CTRL-X CTRL-D	complete defined identifiers
|i_CTRL-X_CTRL-E|	CTRL-X CTRL-E	scroll up
|i_CTRL-X_CTRL-F|	CTRL-X CTRL-F	complete file names
|i_CTRL-X_CTRL-I|	CTRL-X CTRL-I	complete identifiers
|i_CTRL-X_CTRL-K|	CTRL-X CTRL-K	complete identifiers from dictionary
|i_CTRL-X_CTRL-L|	CTRL-X CTRL-L	complete whole lines
|i_CTRL-X_CTRL-N|	CTRL-X CTRL-N	next completion
|i_CTRL-X_CTRL-O|	CTRL-X CTRL-O	omni completion
|i_CTRL-X_CTRL-P|	CTRL-X CTRL-P	previous completion
|i_CTRL-X_CTRL-S|	CTRL-X CTRL-S	spelling suggestions
|i_CTRL-X_CTRL-T|	CTRL-X CTRL-T	complete identifiers from thesaurus
|i_CTRL-X_CTRL-Y|	CTRL-X CTRL-Y	scroll down
|i_CTRL-X_CTRL-U|	CTRL-X CTRL-U	complete with 'completefunc'
|i_CTRL-X_CTRL-V|	CTRL-X CTRL-V	complete like in : command line
|i_CTRL-X_CTRL-Z|	CTRL-X CTRL-Z	stop completion, keeping the text as-is
|i_CTRL-X_CTRL-]|	CTRL-X CTRL-]	complete tags
|i_CTRL-X_s|		CTRL-X s	spelling suggestions

commands in completion mode (see |popupmenu-keys|)

|complete_CTRL-E| CTRL-E	stop completion and go back to original text
|complete_CTRL-Y| CTRL-Y	accept selected match and stop completion
		CTRL-L		insert one character from the current match
		<CR>		insert currently selected match
		<BS>		delete one character and redo search
		CTRL-H		same as <BS>
		<Up>		select the previous match
		<Down>		select the next match
		<PageUp>	select a match several entries back
		<PageDown>	select a match several entries forward
		other		stop completion and insert the typed character
