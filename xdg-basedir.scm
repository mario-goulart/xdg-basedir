(module xdg-basedir

(xdg-home
 xdg-cache-home
 xdg-config-home
 xdg-data-home
 xdg-state-home
 xdg-config-dirs
 xdg-data-dirs
 xdg-runtime-dir
 )

(import (scheme))
(import (chicken base)
        (chicken file)
        (chicken file posix)
        (chicken pathname)
        (chicken process-context))

(define xdg-home
  (make-parameter (get-environment-variable "HOME")))

(define (xdg-bind-home-dir xdg-var home-rel-dir)
  (lambda (#!key (create-directory? #t) (set-environment? #t))
    (let* ((xdg-dir (get-environment-variable xdg-var))
           (var-set? (and xdg-dir (not (string=? "" xdg-dir))))
           (dir (if var-set?
                    xdg-dir
                    (make-pathname (xdg-home) home-rel-dir))))
      (when create-directory?
        (create-directory dir 'parents))
      (when (and set-environment? dir (not var-set?))
        (set-environment-variable! xdg-var dir))
      dir)))

(define (xdg-bind-dir xdg-var fallback-dirs)
  (lambda (#!key (set-environment? #t))
    (let* ((xdg-dirs (get-environment-variable xdg-var))
           (var-set? (and xdg-dirs (not (string=? "" xdg-dirs))))
           (dir (if var-set?
                    xdg-dirs
                    fallback-dirs)))
      (when (and set-environment? dir (not var-set?))
        (set-environment-variable! xdg-var dir))
      dir)))

(define xdg-cache-home
  (xdg-bind-home-dir "XDG_CACHE_HOME" ".cache/"))

(define xdg-config-home
  (xdg-bind-home-dir "XDG_CONFIG_HOME" ".config/"))

(define xdg-data-home
  (xdg-bind-home-dir "XDG_DATA_HOME" ".local/share/"))

(define xdg-state-home
  (xdg-bind-home-dir "XDG_STATE_HOME" ".local/state/"))

(define xdg-data-dirs
  (xdg-bind-dir "XDG_DATA_DIRS" "/usr/local/share/:/usr/share/"))

(define xdg-config-dirs
  (xdg-bind-dir "XDG_CONFIG_DIRS" "/etc/xdg/"))

(define xdg-runtime-dir
  (xdg-bind-dir "XDG_RUNTIME_DIR" #f))

) ;; end module
