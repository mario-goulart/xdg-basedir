(import (chicken base)
        (chicken file)
        (chicken file posix)
        (chicken pathname)
        (chicken process-context))

(import xdg-basedir test)

(define (check-dir xdg-proc #!optional expected-base-dir)
  (let ((dir (xdg-proc))
        (result #t))
    ;; Just in case, since we are deleting directories...
    (assert (not (string=? (xdg-home) (get-environment-variable "HOME"))))
    (handle-exceptions exn
      (set! result #f)
      (assert
       (if expected-base-dir
           (string=? dir expected-base-dir)
           (string=? (substring dir 0 (string-length (xdg-home))) (xdg-home)))))
    (delete-directory dir)
    result))

(define-syntax test-env
  (syntax-rules ()
    ((_ var val)
     (test var val (get-environment-variable var)))))

(define (run-tests)
(test-begin "xdg-basedir")

(test-group "Environment variables unset"
  (unset-environment-variable! "XDG_CACHE_HOME")
  (test-assert "xdg-cache-home" (check-dir xdg-cache-home))

  (unset-environment-variable! "XDG_CONFIG_HOME")
  (test-assert "xdg-config-home" (check-dir xdg-config-home))
  (test-env "XDG_CONFIG_HOME" (xdg-config-home))

  (unset-environment-variable! "XDG_DATA_HOME")
  (test-assert "xdg-data-home" (check-dir xdg-data-home))
  (test-env "XDG_DATA_HOME" (xdg-data-home))

  (unset-environment-variable! "XDG_STATE_HOME")
  (test-assert "xdg-state-home" (check-dir xdg-state-home))
  (test-env "XDG_STATE_HOME" (xdg-state-home))

  (unset-environment-variable! "XDG_DATA_DIRS")
  (test "xdg-data-dirs" "/usr/local/share/:/usr/share/" (xdg-data-dirs))
  (test-env "XDG_DATA_DIRS" "/usr/local/share/:/usr/share/")

  (unset-environment-variable! "XDG_CONFIG_DIRS")
  (test "xdg-config-dirs" "/etc/xdg/" (xdg-config-dirs))
  (test-env "XDG_CONFIG_DIRS" "/etc/xdg/")

  (unset-environment-variable! "XDG_RUNTIME_DIR")
  (test "xdg-runtime-dir" #f (xdg-runtime-dir))
  (test-env "XDG_RUNTIME_DIR" #f))

(test-group "Environment variables set"
  (let ((test-dir (make-pathname (xdg-home) "foo")))
    (set-environment-variable! "XDG_CACHE_HOME" test-dir)
    (test-assert "xdg-cache-home" (check-dir xdg-cache-home test-dir))
    (test-env "XDG_CACHE_HOME" test-dir)

    (set-environment-variable! "XDG_CONFIG_HOME" test-dir)
    (test-assert "xdg-config-home" (check-dir xdg-config-home test-dir))
    (test-env "XDG_CONFIG_HOME" test-dir)

    (set-environment-variable! "XDG_DATA_HOME" test-dir)
    (test-assert "xdg-data-home" (check-dir xdg-data-home test-dir))
    (test-env "XDG_DATA_HOME" test-dir)

    (set-environment-variable! "XDG_STATE_HOME" test-dir)
    (test-assert "xdg-state-home" (check-dir xdg-state-home test-dir))
    (test-env "XDG_STATE_HOME" test-dir))

  (set-environment-variable! "XDG_DATA_DIRS" "foo:bar")
  (test "xdg-data-dirs" "foo:bar" (xdg-data-dirs))
  (test-env "XDG_DATA_DIRS" "foo:bar")

  (set-environment-variable! "XDG_CONFIG_DIRS" "foo:bar")
  (test "xdg-config-dirs" "foo:bar" (xdg-config-dirs))
  (test-env "XDG_CONFIG_DIRS" "foo:bar")

  (set-environment-variable! "XDG_RUNTIME_DIR" "foo")
  (test "xdg-runtime-dir" "foo" (xdg-runtime-dir))
  (test-env "XDG_RUNTIME_DIR" "foo"))

(test-end "xdg-basedir"))

(xdg-home (create-temporary-directory))

(define (clean-up)
  (assert (not (string=? (xdg-home) (get-environment-variable "HOME"))))
  (delete-directory (xdg-home) 'recursively))

(handle-exceptions exn
  (clean-up)
  (run-tests)
  (clean-up))

(test-exit)
