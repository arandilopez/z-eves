;;; Z-EVES Project
;;; File:   z-eves.el - GNU Emacs major mode for Z-EVES editing and processing,
;;;                     for Emacs Version 19
;;; Author: Irwin Meisels

;;; To use this mode, install z-eves.elc in your Emacs site-lisp directory, and
;;; put the following in your .emacs file:
;;;
;;; (setq auto-mode-alist (append auto-mode-alist
;;;                               '(("\\.z$" . z-latex-mode)
;;;                                 ("\\.zed$" . z-latex-mode))))
;;; (autoload 'z-latex-mode "z-eves" "Z-EVES LaTeX mode." t)
;;; (autoload 'run-z-eves "z-eves" "Run Z-EVES." t)
;;; (setq z-eves-program "<pathname of z-eves program>")
;;; (setq z-eves-program-args <list of arguments, or nil>)
;;;
;;; If your source file has an extension of .tex, you will have to turn on
;;; z-latex-mode (M-x z-latex-mode) after reading it, or add a cons for ".tex"
;;; to your auto-mode-alist for z-latex mode.

(require 'comint)
(require 'dabbrev)
(require 'etags)

;;; Functions for creating start regexps from lists of "start symbols".
;;; A start symbol is either a symbol, or list of symbols if the command starts
;;; with more than one token.

;;; Return true if start sym 1 < start sym 2

(defun z-eves-start-sym-pred (sym1 sym2)
  (z-eves-start-sym-pred-aux (if (atom sym1) (list sym1) sym1)
			     (if (atom sym2) (list sym2) sym2)))

(defun z-eves-start-sym-pred-aux (sym1 sym2)
  (cond
   ((null sym1)
    t)
   ((null sym2)
    nil)
   ((string< (car sym1) (car sym2))
    t)
   ((string= (car sym1) (car sym2))
    (z-eves-start-sym-pred-aux (cdr sym1) (cdr sym2)))
   (t
    nil)))
    
;;; Return true if start sym 1 is a subset of start sym 2

(defun z-eves-is-dupsym (sym1 sym2)
  (z-eves-is-dupsym-aux (if (atom sym1) (list sym1) sym1)
			(if (atom sym2) (list sym2) sym2)))

(defun z-eves-is-dupsym-aux (sym1 sym2)
  (cond
   ((null sym1)
    t)
   ((null sym2)
    nil)
   ((string= (car sym1) (car sym2))
    (z-eves-is-dupsym-aux (cdr sym1) (cdr sym2)))
   (t
    nil)))

;;; Remove start syms from the argument list that have subsets.

(defun z-eves-remove-dupsyms (syms)
  (let (result)
    (while syms
      (cond
       ((z-eves-is-dupsym (car syms) (car (cdr syms)))
	(setq syms (cons (car syms) (cdr (cdr syms)))))
       (t
	(setq result (cons (car syms) result))
	(setq syms (cdr syms)))))
    (nreverse result)))

;;; Create a regexp from a start symbol.

(defun z-eves-start-sym-regexp (sym)
  (if (atom sym)
      (regexp-quote (symbol-name sym))
    (concat "\\("
	    (mapconcat (function z-eves-start-sym-regexp) sym " +")
	    "\\)")))

;;; Create a regexp from a list of start syms.

(defun z-eves-make-start-regexp (syms)
  (setq syms (z-eves-remove-dupsyms (sort syms 'z-eves-start-sym-pred)))
  (concat "^\\("
	  (mapconcat (function z-eves-start-sym-regexp)
		     syms
		     "\\|")
	  "\\)"))

;;; Z-LaTeX major mode definitions and functions

(defvar z-latex-start-command nil
  "String for sending to Z-EVES to start Z-LaTeX mode.
If nil, nothing is sent.")

(defvar z-latex-proof-summary-command "print proof summary;"
  "String for eliciting a proof summary from Z-EVES in Z-LaTeX mode.")

(defvar z-latex-prompt "=> *"
  "Regexp to recognize prompts from Z-EVES in Z-LaTeX mode.")

;;; Start symbols for Z-LaTeX declarations and commands.

(defconst z-latex-declarations
  '(\\syndef{ \\include{ \\input{
    \\begin{zed} \\begin{syntax} \\begin{axdef} \\begin{schema} \\begin{gendef}
    \\begin{theorem} \\begin\[enabled\] \\begin\[disabled\]
    \\begin{zproof}
    \\begin{zsection} \\end{zsection}
    \\begin{zsectionproof} \\end{zsectionproof}))

(defconst z-latex-commands
  '(apply (apply to expression) (apply to predicate)
    back cases check conjunctive declare (declare to) (declare through)
    disjunctive (equality substitute) help instantiate
    invoke (invoke predicate)
    next parent prenex (print declaration) (print formula) (print history)
    (print history summary) (print proof) (print proof summary) (print status)
    (print syntax) (print theorems about expression)
    (print theorems about predicate)
    prove (prove by reduce) (prove by rewrite)
    quit read (read declarations) (read proofs) (read script)
    rearrange reduce reset retry rewrite simplify
    split (theorems about expression) (theorems about predicate)
    (trivial rewrite) (trivial simplify)
    try (try lemma) undo (undo back to) (undo back through) use
    (with disabled) (with enabled) (with expression)
    (with normalization) (with predicate) (zsection path) ztags))

;;; These commands are not executed if an argument is given to
;;; z-eves-evaluate-region.

(defconst z-latex-proof-commands
  '(apply (apply to expression) (apply to predicate)
    back cases conjunctive disjunctive (equality substitute) instantiate
    invoke (invoke predicate)
    next prenex (print formula) (print proof) (print proof summary)
    prove (prove by reduce) (prove by rewrite)
    rearrange reduce retry rewrite simplify
    split (trivial rewrite) (trivial simplify)
    try (try lemma) use
    (with disabled) (with enabled) (with expression)
    (with normalization) (with predicate)
    \\begin{zproof}))

(defconst z-latex-directives
  '(%%inop %%postop %%inrel %%prerel %%ingen %%pregen %%ignore))

;;; A regexp for finding the start of a Z-LaTeX declaration or command.

(defvar z-latex-start-regexp nil)

(if z-latex-start-regexp
    nil
  (setq z-latex-start-regexp
    (z-eves-make-start-regexp (append z-latex-declarations
				      z-latex-commands
				      z-latex-directives))))

;;; A regexp for finding the beginning of a Z-LaTeX proof command.

(defvar z-latex-proof-start-regexp nil)

(if z-latex-proof-start-regexp
    nil
  (setq z-latex-proof-start-regexp
    (z-eves-make-start-regexp z-latex-proof-commands)))

;;; Z/LaTeX commands that fit on one (logical) line. If point is at the
;;; beginning of one of the keys in this alist, the end of the command is n
;;; balanced paren pairs after the end of the key, where n is the associated
;;; data.

(defconst z-latex-one-liners
  '((\\syndef . 3)
    (\\include . 1)
    (\\input . 1)
    (\\begin{zsection} . 2)
    (\\begin{zsectionproof} . 2)
    (\\end{zsection} . 0)
    (\\end{zsectionproof} . 0)))

;;; A regexp for determining if we are looking at a "one-liner".

(defvar z-latex-one-liner-regexp nil)

(if z-latex-one-liner-regexp
    nil
  (setq z-latex-one-liner-regexp
    (z-eves-make-start-regexp (mapcar 'car z-latex-one-liners))))

(defvar z-latex-mode-map nil)

(if z-latex-mode-map
    nil
  (setq z-latex-mode-map (make-sparse-keymap))
  (define-key z-latex-mode-map "\C-c\C-l" 'run-z-eves)
  (define-key z-latex-mode-map "\C-c\C-b" 'z-latex-backward-command)
  (define-key z-latex-mode-map "\C-c\C-e" 'z-eves-evaluate-command)
  (define-key z-latex-mode-map "\C-c\C-f" 'z-latex-forward-command)
  (define-key z-latex-mode-map "\C-c\C-r" 'z-eves-evaluate-region)
  (define-key z-latex-mode-map "\C-c\C-s" 'z-eves-print-proof-summary)
  (define-key z-latex-mode-map "\C-?" 'backward-delete-char-untabify)
  (define-key z-latex-mode-map "\C-j" 'z-latex-newline-and-indent)
  (define-key z-latex-mode-map "\C-i" 'z-latex-tab-or-complete)
  )

;;; Set up things for Z-LaTeX mode.

(defun z-latex-buffer-setup ()
  ;;??? set up syntax table
  (make-local-variable 'comment-start)
  (setq comment-start "%")
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "%+ *")
  (make-local-variable 'comment-column)
  (setq comment-column 40)
  (make-local-variable 'z-eves-mode-map)
  (setq z-eves-mode-map (copy-keymap comint-mode-map))
  (define-key z-eves-mode-map "\C-?" 'backward-delete-char-untabify)
  (define-key z-eves-mode-map "\C-j" 'z-latex-newline-and-indent)
  (define-key z-eves-mode-map "\C-i" 'z-latex-tab-or-complete)
  (make-local-variable 'z-eves-start-command)
  (setq z-eves-start-command z-latex-start-command)
  (make-local-variable 'z-eves-proof-summary-command)
  (setq z-eves-proof-summary-command z-latex-proof-summary-command)
  (make-local-variable 'z-eves-prompt)
  (setq z-eves-prompt z-latex-prompt)
  (make-local-variable 'z-eves-command-near-point)
  (setq z-eves-command-near-point 'z-latex-command-near-point)
  (make-local-variable 'z-eves-commands-in-region)
  (setq z-eves-commands-in-region 'z-latex-commands-in-region)
  (make-local-variable 'z-eves-buffer-setup)
  (setq z-eves-buffer-setup 'z-latex-buffer-setup)

  ;; Add the Z/LaTeX tags search initializer
  (add-hook 'tags-table-format-hooks 'z-latex-recognize-tags-table))

(defun z-latex-mode ()
  "Major mode for editing Z specifications in Z-LaTeX syntax.
Commands:

\\{z-latex-mode-map}
Entry to this mode runs the hooks on `z-latex-mode-hook'."
  (interactive)
  (kill-all-local-variables)
  (use-local-map z-latex-mode-map)
  (z-latex-buffer-setup)
  (setq major-mode 'z-latex-mode)
  (setq mode-name "z-latex")
  (run-hooks 'z-latex-mode-hook))

(defun z-latex-forward-command (arg)
  "Move forward to the beginning of the next Z-LaTeX declaration or command.
With arg, move to the beginning of the arg'th next one."
  (interactive "p")
  (if (looking-at z-latex-start-regexp)
      (setq arg (1+ arg)))
  (if (re-search-forward z-latex-start-regexp nil t arg)
      (beginning-of-line)
    (error "No next Z-LaTeX declaration or command")))

;;; Return true if point is on a line that starts a Z-LaTeX command. This
;;; kludge is needed because re-search-backward fails to match a string if
;;; the current point is in the string.

(defun z-latex-command-on-line ()
  (save-excursion
    (beginning-of-line)
    (looking-at z-latex-start-regexp)))

;;; Find the end of a Z-LaTeX declaration or command. Point must be at the
;;; start of the declaration or command. Returns t if found, nil otherwise.

(defun z-latex-end-decl-or-command ()
  (cond
   ((looking-at "^%%")
    (end-of-line 1)
    t)
   ((looking-at z-latex-one-liner-regexp)
    (let* ((text (buffer-substring (match-beginning 0) (match-end 0)))
	   (sym (intern text))
	   (n (cdr (assq sym z-latex-one-liners))))
      (if (not n)
	  (error "Not a valid start: %s" text))
      (goto-char (match-end 0))
      (forward-list n)
      t))
   ((looking-at "^\\\\begin")
    (cond
     ((re-search-forward "^\\\\end{" nil t)
      (end-of-line 1)
      t)
     (t
      nil)))
   (t
    (re-search-forward ";[ \t]*$" nil t))))

(defun z-latex-backward-command (arg)
  "Move backward to the beginning of the current Z-LaTeX declaration or
command. With arg, move to the beginning of the arg'th previous one."
  (interactive "p")
  (cond
   ((and (not (bolp)) (z-latex-command-on-line))
    (beginning-of-line)
    (setq arg (max (1- arg) 0))))
  (if (not (re-search-backward z-latex-start-regexp nil t arg))
      (error "No previous Z-LaTeX declaration or command")))

;;; Z-LaTeX-specific navigation functions for Z-EVES evaluation

;;; If point is at the beginning of, inside, or at the end of a Z-LaTeX decl or
;;; command, return a cons containing the start and end points of the command.
;;; Otherwise, signals an error.

(defun z-latex-command-near-point ()
  (let (start end)
    (save-excursion
      (cond
       ((z-latex-command-on-line)
	(beginning-of-line)
	(setq start (point)))
       ((re-search-backward z-latex-start-regexp nil t)
	(setq start (point)))
       (t
	(error "Can't find start of Z-LaTeX command.")))
      (if (not (z-latex-end-decl-or-command))
	  (error "Can't find end of Z-LaTeX command"))
      (setq end (point)))
    (cons start end)))

;;; Return t if pt is inside a Z-LaTeX command, nil otherwise.

(defun z-latex-in-command-p (pt)
  (save-excursion
    (goto-char pt)
    (cond
     ((z-latex-command-on-line)
      (not (bolp)))
     (t
      (and (re-search-backward z-latex-start-regexp nil t)
	   (z-latex-end-decl-or-command)
	   (> (point) pt))))))

;;; Return t if there is a complete Z-LaTeX command between start and end,
;;; nil otherwise.

(defun z-latex-command-in-region-p (start end)
  (save-excursion
    (goto-char start)
    (and (or (looking-at z-latex-start-regexp)
	      (re-search-forward z-latex-start-regexp nil t))
	 (z-latex-end-decl-or-command)
	 (<= (point) end))))

;;; Return non-nil if the Z-LaTeX command at pt is a proof command,
;;; nil otherwise.

(defun z-latex-proof-command-p (pt)
  (save-excursion
    (beginning-of-line)
    (looking-at z-latex-proof-start-regexp)))

;;; Find the beginning and end points of all Z-LaTeX commands in a region.
;;; Returns a list of conses.
;;; If noproof is non-nil, proof commands are ignored.

(defun z-latex-commands-in-region (noproof start end)
  (let ((pts nil)
	pos)
    (save-excursion
      (if (z-latex-in-command-p start)
	  (error "Region starts in the middle of a Z-LaTeX command."))
      (if (z-latex-in-command-p end)
	  (error "Region ends in the middle of a Z-LaTeX command."))
      (if (not (z-latex-command-in-region-p start end))
	  (error "Region contains no Z-LaTeX commands."))
      (goto-char start)
      (let (pos)
	(while (and (or (looking-at z-latex-start-regexp)
			(prog1
			    (re-search-forward z-latex-start-regexp nil t)
			  (beginning-of-line)))
		    (< (point) end))
	  (if (and noproof
		   (z-latex-proof-command-p (point)))
	      (z-latex-end-decl-or-command)
	    (setq pos (point))
	    (z-latex-end-decl-or-command)
	    (setq pts (cons (cons pos (point)) pts))))))
    (nreverse pts)))

(defun z-latex-newline-and-indent ()
  "Insert a newline and indent to indent column of now-previous line."
  (interactive)
  (let ((col (save-excursion
	       (back-to-indentation)
	       (current-column))))
    (insert "\n")
    (indent-to col)))

(defun z-latex-tab-or-complete (arg)
  "If at the beginning of a line, or the char before point is not a
symbol char, insert a tab. Otherwise, try to complete the symbol
before point."
  (interactive "*P")
  (if (bolp)
      (insert ?\t)
    (let ((cs (char-syntax (preceding-char))))
      (if (or (= cs (char-syntax ?a))
	      (= cs (char-syntax ?_)))
	  (dabbrev-expand arg)
	(insert ?\t)))))

;;; Modified version of etags-recognize-tags-table
;;; - makes searches and matches in tags file case-sensitive
;;; - uses Z/LaTeX goto tag function
;;; - limits tag matching in tags file
;;; If previous buffer wasn't in a recognized mode, return nil.

(defun z-latex-recognize-tags-table ()
  ;; We are in the tags buffer, and we want the major mode of the buffer the
  ;; tags search command was issued in. Gross.
  (let* ((prevbuf (car (buffer-list)))
	 (mode (cdr (assq 'major-mode (buffer-local-variables prevbuf)))))
    (cond
     ((not (memq mode '(z-latex-mode z-eves-mode latex-mode)))
      nil)
     ((etags-verify-tags-table)
      (mapcar (function (lambda (elt)
			  (set (make-local-variable (car elt)) (cdr elt))))
	      '((file-of-tag-function . etags-file-of-tag)
		(tags-table-files-function . etags-tags-table-files)
		(tags-completion-table-function . etags-tags-completion-table)
		(snarf-tag-function . etags-snarf-tag)
		(goto-tag-location-function . z-latex-goto-tag-location)
		(find-tag-regexp-search-function . re-search-forward)
		(find-tag-regexp-tag-order . (tag-re-match-p))
		(find-tag-regexp-next-line-after-failure-p . t)
		(find-tag-search-function . search-forward)
		(find-tag-tag-order . (z-latex-tag-exact-match-p))
		(find-tag-next-line-after-failure-p . nil)
		(list-tags-function . etags-list-tags)
		(tags-apropos-function . etags-tags-apropos)
		(tags-included-tables-function . etags-tags-included-tables)
		(verify-tags-table-function . etags-verify-tags-table)
		))
      (setq case-fold-search nil)
      t)
     (t nil))))

;;; tag-exact-match-p from Emacs 19.31, in case we are running on an older
;;; version.

(defun z-latex-tag-exact-match-p (tag)
  ;; The match is really exact if there is an explicit tag name.
  (or (and (eq (char-after (point)) ?\001)
	   (eq (char-after (- (point) (length tag) 1)) ?\177))
      ;; We are not on the explicit tag name, but perhaps it follows.
      (looking-at (concat "[^\177\n]*\177" (regexp-quote tag) "\001"))))


;;; Modified version of etags-goto-tags-location
;;; - searches and matches are case-sensitive
;;; - tag pattern is a regexp, and is not regexp-quoted
;;; - first look for the tag pattern is a search, not looking-at
;;; - moves to start of tag pattern after finding it

(defun z-latex-goto-tag-location (tag-info)
  (let ((startpos (cdr (cdr tag-info)))
	(case-fold-search nil)
	offset found pat)
    (if (eq (car tag-info) t)
	;; Direct file tag.
	(cond (line (goto-line line))
	      (position (goto-char position))
	      (t (error "etags.el BUG: bogus direct file tag")))
      ;; This constant is 1/2 the initial search window.
      ;; There is no sense in making it too small,
      ;; since just going around the loop once probably
      ;; costs about as much as searching 2000 chars.
      (setq offset 1000
	    found nil
	    pat (concat (if (eq selective-display t)
			    "\\(^\\|\^m\\)" "")
			(car tag-info)))
      ;; The character position in the tags table is 0-origin.
      ;; Convert it to a 1-origin Emacs character position.
      (if startpos (setq startpos (1+ startpos)))
      ;; If no char pos was given, try the given line number.
      (or startpos
	  (if (car (cdr tag-info))
	      (setq startpos (progn (goto-line (car (cdr tag-info)))
				    (point)))))
      (or startpos
	  (setq startpos (point-min)))
      ;; First see if the tag is right at the specified location.
      (goto-char startpos)
      (setq found (re-search-forward pat (+ startpos offset) t))
      (while (and (not found)
		  (progn
		    (goto-char (- startpos offset))
		    (not (bobp))))
	(setq found
	      (re-search-forward pat (+ startpos offset) t)
	      offset (* 3 offset)))	; expand search window
      (or found
	  (re-search-forward pat nil t)
	  (error "Rerun etags: `%s' not found in %s"
		 pat buffer-file-name)))
    ;; Position point at the right place
    ;; if the search string matched an extra Ctrl-m at the beginning.
    (goto-char (match-beginning 0))))

;;; Commands and definitions for running an inferior Z-EVES processor.

;;; Generic Z-EVES definitions, set to specific values by the mode start
;;; functions. The default mode start function is for Z-LaTeX mode.
;;; These should not be set by the user; set the language-specific variables
;;; instead.

;;; Function to call to set up the Z-EVES buffer for mode-specific editing.

(defvar z-eves-buffer-setup 'z-latex-buffer-setup)

;;; Local map for Z-EVES buffer, set by mode-specific setup function.

(defvar z-eves-mode-map)

;;; String for eliciting a proof summary from Z-EVES.

(defvar z-eves-proof-summary-command)

;;; Regexp to recognize prompts from Z-EVES.

(defvar z-eves-prompt)

;;; String to send to Z-EVES to start the command processor.
;;; If nil, nothing is sent.

(defvar z-eves-start-command)

;;; Function which gives the beginning and end points of the Z-EVES command
;;; near point.

(defvar z-eves-command-near-point)

;;; Function which returns a list of beginning and end points of Z-EVES
;;; commands in a region.

(defvar z-eves-commands-in-region)

(defun z-eves-mode ()
  "Major mode for interacting with an inferior Z-EVES processor process.
Runs the Z-EVES program as a subprocess of Emacs, with I/O through an
Emacs buffer. The name of this program is the value of the variable
z-eves-program.  If the current buffer is in a mode for a language recognized
by Z-EVES, initialization specific to that language is done in the Z-EVES
buffer. Otherwise, Z-LaTeX-specific initialization is done.
Starts the Z-EVES program by sending it the value of the variable
z-eves-start-command, if it is non-nil.
Entry to this mode runs the hooks on `comint-mode-hook' and
`z-eves-mode-hook', in that order."
  (interactive)
  (comint-mode)
  ;; Customization
  (funcall z-eves-buffer-setup)
  (setq comint-prompt-regexp z-eves-prompt)
  (setq major-mode 'z-eves-mode)
  (setq mode-name "Z-EVES")
  (setq mode-line-process '(": %s"))
  (use-local-map z-eves-mode-map)
  (run-hooks 'z-eves-mode-hook))


(defun run-z-eves (arg)
  "Run an inferior Z-EVES process, input and output via buffer *z-eves*.
This buffer is set to Z-EVES mode; see the documentation for z-eves-mode for
details. With an argument, or if the variable z-eves-program is nil, asks
for the name of the program to run and options to pass to the program."
  (interactive "P")
  (when (or arg (null z-eves-program))
    (setq z-eves-program
      (expand-file-name (read-file-name "Z/EVES program: " nil
					z-eves-program t)))
    (setq z-eves-program-args
      (parse-words-from-string
       (read-string "Z/EVES program args: "
		    (mapconcat #'identity z-eves-program-args " ")))))
  (let ((modefun z-eves-buffer-setup))
    (save-window-excursion
      (if (not (comint-check-proc "*z-eves*"))
	  (let* ((buf (set-buffer (apply #'make-comint "z-eves" z-eves-program
					 nil z-eves-program-args)))
		 (proc (get-buffer-process buf)))
	    (setq z-eves-buffer-setup modefun)
	    (z-eves-mode)
	    (cond
	     (z-eves-start-command
	      (comint-send-string proc z-eves-start-command)
	      (comint-send-string proc "\n")))))
      (setq z-eves-buffer "*z-eves*")
      (switch-to-buffer "*z-eves*"))
    (pop-to-buffer "*z-eves*")))

;;; Break up argument string into a list of words.

(defun parse-words-from-string (str)
  (let ((start 0)
	(words nil))
    (while (string-match "[^ \t]+" str start)
      (setq words (cons (substring str (match-beginning 0) (match-end 0))
			words))
      (setq start (match-end 0)))
    (nreverse words)))

;;; Returns the current Z-EVES process, if there is one. Otherwise, signals an
;;; error.

(defun z-eves-proc ()
  (let ((proc (get-buffer-process (if (eq major-mode 'z-eves-mode)
				      (current-buffer)
				      z-eves-buffer))))
    (or proc
	(error "No current Z-EVES process."))))

;;; Send a string to the inferior Z-EVES process. If the string does not end
;;; in a newline, one is sent to the process.

(defun z-eves-send-string (cmd &optional display)
  (let ((process (z-eves-proc)))
    (comint-send-string process cmd)
    (if (not (= (aref cmd (1- (length cmd))) ?\n))
	(comint-send-string process "\n"))))

;;; Like z-eves-send-string, except a specified region is sent.

(defun z-eves-send-region (start end)
  (z-eves-send-string (buffer-substring start end)))

(defun z-eves-evaluate-command ()
  "Send the Z-EVES command which starts near point to the Z-EVES processor."
  (interactive)
  (let ((pts (funcall z-eves-command-near-point)))
    (z-eves-send-region (car pts) (cdr pts))))

(defun z-eves-evaluate-region (noproof start end)
  "Send all Z-EVES commands between point and mark to the Z-EVES processor.
Point and mark must not be within an Z-EVES command, and there must be
at least one complete Z-EVES command in the region. If noproof is non-nil,
only declarations will be sent to the Z-EVES processor."
  (interactive "P\nr")
  (let ((pts (funcall z-eves-commands-in-region noproof start end)))
    (while pts
      (z-eves-send-region (car (car pts)) (cdr (car pts)))
      (setq pts (cdr pts)))))

(defvar z-eves-proc-finished nil)

(defun z-eves-print-proof-summary (arg)
  "Insert a proof summary after point in the current buffer.
Sets the mark to the start of the proof summary, and leaves point at the end.
With arg, inserts the summary in a zproof box."
  (interactive "P")
  (setq proc-out nil)
  (setq z-eves-proc-finished nil)
  (let ((process (z-eves-proc))
	(start (point)))
    (set-process-filter process 'z-eves-insert-process-output)
    (z-eves-send-string z-eves-proof-summary-command)
    (while (not z-eves-proc-finished)
      (accept-process-output process))
    (delete-char -1)			; get rid of the extra newline
    (when arg
      (z-eves-massage-proof-summary start (point)))
    (push-mark start)))

;;; Insert output from process until z-eves-prompt is read.

(defun z-eves-insert-process-output (process str)
  (insert str)
  (save-excursion
    (beginning-of-line)
    (if (looking-at z-eves-prompt)
	(progn
	  (replace-match "")		; delete prompt
	  (set-process-filter process 'comint-output-filter)
	  (setq z-eves-proc-finished t)))))

;;; Turn a proof summary into a zproof box. start and end are where the proof
;;; summary begins and ends. Leaves point at the end of the box.

(defun z-eves-massage-proof-summary (start end)
  (let ((endp (make-marker)))
    (set-marker endp end)
    (goto-char start)
    (while (and (< (point) end) (looking-at "^[ \t]*$"))
      (forward-line))
    (cond
     ((>= (point) end)
      ;; no proof
      (goto-char endp))
     ((looking-at "^try lemma \\([^;]+\\);$")
      ;; grab the name and add it as an argument to the box
      (let ((name (buffer-substring (match-beginning 1) (match-end 1))))
	(delete-region start (save-excursion (end-of-line) (point)))
	(insert "\\begin{zproof}[" name "]")
	(goto-char endp)
	(insert "\\end{zproof}\n")))
     ((looking-at "^try ")
      ;; no name, but at least there is a try command
      (delete-region start (save-excursion (end-of-line) (point)))
      (insert "\\begin{zproof}")
      (goto-char endp)
      (insert "\\end{zproof}\n"))
     (t
      ;; don't know what it is - leave it alone
      (goto-char endp)))
    (set-marker endp nil)))
