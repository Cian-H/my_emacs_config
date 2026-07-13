{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = [
    pkgs.git
    ((pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages (epkgs: [
      epkgs.elisp-lint
    ]))
  ];

  scripts = {
    typecheck.exec = ''
      emacs --batch --eval "(progn (advice-add 'require :around (lambda (orig &rest args) (condition-case nil (apply orig args) (error (message \"Mocked load: %s\" (car args)) t)))) (defun general-define-key (&rest _args) nil) (defun my-leader-def (&rest _args) nil) (defun general-create-definer (&rest _args) (lambda (&rest _a) nil)) (defun general-evil-setup (&rest _args) nil))" -L . -L lisp -f batch-byte-compile early-init.el init.el lisp/*.el
      rm -f early-init.elc init.elc lisp/*.elc
    '';

    syntax-check.exec = ''
      emacs --batch --eval "(mapc (lambda (f) (with-temp-buffer (insert-file-contents f) (condition-case err (while t (read (current-buffer))) (end-of-file nil) (error (message \"Syntax error in %s: %s\" f err) (kill-emacs 1))))) '(\"early-init.el\" \"init.el\" \"lisp/setup-completion.el\" \"lisp/setup-editor.el\" \"lisp/setup-evil.el\" \"lisp/setup-git.el\" \"lisp/setup-lisp.el\" \"lisp/setup-lsp.el\" \"lisp/setup-org.el\" \"lisp/setup-ui.el\"))"
    '';

    lint.exec = "devenv shell typecheck && devenv shell syntax-check";

    format.exec = ''
      for file in early-init.el init.el lisp/*.el; do
        echo "Formatting $file..."
        emacs -Q --batch "$file" --eval "(indent-region (point-min) (point-max))" -f save-buffer 2>/dev/null
      done
    '';

    smoketest.exec = ''
      PROFILE_DIR="$PWD/.devenv/test-profile/emacs"
      mkdir -p "$PROFILE_DIR"

      # Symlink config files to local sandbox config path
      ln -sfn "$PWD/init.el" "$PROFILE_DIR/init.el"
      ln -sfn "$PWD/early-init.el" "$PROFILE_DIR/early-init.el"
      ln -sfn "$PWD/lisp" "$PROFILE_DIR/lisp"

      echo "Running isolated Emacs smoketest..."
      emacs --batch --init-directory "$PROFILE_DIR" -L "$PROFILE_DIR" -L "$PROFILE_DIR/lisp" --eval '(load "early-init")' --eval '(load "init")'
    '';

    test-drive.exec = ''
      PROFILE_DIR="$PWD/.devenv/test-profile/emacs"
      mkdir -p "$PROFILE_DIR"

      # Symlink config files to local sandbox config path
      ln -sfn "$PWD/init.el" "$PROFILE_DIR/init.el"
      ln -sfn "$PWD/early-init.el" "$PROFILE_DIR/early-init.el"
      ln -sfn "$PWD/lisp" "$PROFILE_DIR/lisp"

      echo "Starting test-drive of Emacs in isolated sandbox..."
      echo "Caches, package downloads (ELPA), and state will be saved to: $PROFILE_DIR"

      emacs --init-directory "$PROFILE_DIR" "$@"
    '';
  };
}
