;;; setup-lsp.el --- LSP and Code Intelligence -*- lexical-binding: t; -*-

;; Eglot: built-in, high-performance LSP client
(use-package eglot
  :hook ((python-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (lua-mode . eglot-ensure)
         (nix-mode . eglot-ensure)
         (elixir-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t)            ; Shutdown server when last buffer is closed
  (setq eglot-events-buffer-size 0)      ; Performance: disable verbose event logging
  
  ;; Format on save (mirrors conform.nvim's format_on_save)
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'eglot-format-buffer nil t)))
  )

;; Consult-eglot: integrates Consult fuzzy search with LSP symbols (Telescope lsp_document_symbols)
(use-package consult-eglot
  :ensure t
  :after (consult eglot))

;; Configure LSP Keybindings
(with-eval-after-load 'eglot
  ;; Normal mode buffer-local bindings
  (general-define-key
   :states 'normal
   :keymaps 'eglot-mode-map
   "K" 'eldoc                          ; Hover documentation
   "gd" 'xref-find-definitions          ; Go to definition
   "gi" 'eglot-find-implementation      ; Go to implementation
   "gr" 'xref-find-references          ; Go to references
   "gt" 'eglot-find-typeDefinition)    ; Go to type definition

  ;; Leader bindings when LSP is active
  (my-leader-def
   :keymaps 'eglot-mode-map
   "ca" 'eglot-code-actions            ; SPC c a: Code Action
   "r"  'eglot-rename                  ; SPC r: Rename symbol
   "f"  'eglot-format-buffer           ; SPC f: Format buffer
   "ci" 'eglot-inlay-hints-mode        ; SPC c i: Toggle inlay hints
   "dd" 'consult-flymake               ; SPC d d: Show Diagnostics
   "ss" 'consult-eglot-symbols         ; SPC s s: Search Symbols
   )
  )

(provide 'setup-lsp)
