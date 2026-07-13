;;; setup-completion.el --- Completion and fuzzy finding -*- lexical-binding: t; -*-

;; Vertico: vertical completion UI in minibuffer (like Telescope prompt list)
(use-package vertico
  :ensure t
  :config
  (vertico-mode 1)
  (setq vertico-scroll-margin 2
        vertico-count 15
        vertico-resize nil))

;; Savehist: persist minibuffer history across sessions
(use-package savehist
  :init
  (savehist-mode 1))

;; Orderless: powerful fuzzy completion style (matches space-separated terms in any order)
(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia: add descriptions, types, and values next to completions in the minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;; Consult: rich selection and search commands (similar to Telescope pickers)
(use-package consult
  :ensure t
  :config
  (setq consult-preview-key 'any)) ; Preview buffer selections live as you scroll

;; Corfu: high-performance in-buffer autocomplete popup (equivalent to blink.cmp)
(use-package corfu
  :ensure t
  :config
  (global-corfu-mode 1)
  (setq corfu-cycle t                ; Cycle through suggestions
        corfu-auto t                 ; Enable auto-completion
        corfu-auto-delay 0.1         ; Delay in seconds before popup appears
        corfu-auto-prefix 1          ; Trigger completion after typing 1 character
        corfu-quit-at-boundary nil   ; Keep autocomplete open across spaces if needed
        corfu-quit-no-match t        ; Quit if no match is found
        corfu-preselect 'prompt)     ; Preselect the prompt/first item

  ;; Integrate Corfu with Evil's insert mode
  (with-eval-after-load 'evil
    (evil-make-overriding-map corfu-map 'insert)
    ;; Bind tab keys for navigating suggestions (mirrors blink.cmp "super-tab" preset)
    (define-key corfu-map (kbd "<tab>") 'corfu-next)
    (define-key corfu-map (kbd "<backtab>") 'corfu-previous)
    (define-key corfu-map (kbd "TAB") 'corfu-next)
    (define-key corfu-map (kbd "S-TAB") 'corfu-previous)
    (define-key corfu-map (kbd "RET") 'corfu-insert)))

;; Cape: completion sources (provides file paths, dictionary words, etc. to Corfu)
(use-package cape
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;; Map completing keybindings under SPC leader using general.el
(with-eval-after-load 'general
  (my-leader-def
   ;; Search Group (<leader>s)
   "sf" 'consult-find              ; [S]earch [F]iles (Telescope find_files)
   "sg" 'consult-ripgrep           ; [S]earch by [G]rep (Telescope live_grep)
   "sw" 'consult-line-multi        ; [S]earch current [W]ord across open buffers
   "sd" 'consult-compile-error     ; [S]earch [D]iagnostics
   "s." 'consult-recent-file       ; [S]earch Recent Files (Telescope oldfiles)
   "s/" 'consult-ripgrep           ; [S]earch in open files
   "sh" 'describe-bindings         ; [S]earch [H]elp
   "sk" 'describe-bindings         ; [S]earch [K]eymaps

   ;; Global quick searches
   "<leader>" 'consult-buffer      ; SPC SPC: Find existing buffers
   "/" 'consult-line))             ; SPC /: Fuzzily search in current buffer

(provide 'setup-completion)
