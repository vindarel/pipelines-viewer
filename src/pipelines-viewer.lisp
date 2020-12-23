
(defpackage pipelines-viewer
  (:use :cl))

(in-package :pipelines-viewer)

(defparameter +gitlab-server+ "https://gitlab.com")

(defparameter +gitlab-api-pipelines+ "/api/v4/projects/~a/pipelines"
  "API endpoint with project-id placeholder.")

(defvar *server* +gitlab-server+)

(defun build-url (project-id)
  (str:concat *server* (format nil +gitlab-api-pipelines+ project-id)))

(defun get-pipelines (project-id)
  (let* ((url (build-url project-id))
         (http-result (dex:get url)))
    (jojo:parse http-result)))

(defun is-success (pipeline)
  (string-equal (access:access pipeline :|status|)
                "success"))


(defun is-error (pipeline)
  (string-equal (access:access pipeline :|status|)
                "failed"))

(defun show-last-pipelines (data)
  (loop for item in (str:substring 0 10 data)
     do (cond
          ((is-success item)
           (format t "~a~t ~a~&"
                   (cl-ansi-text:green "OK")
                   (access:access item :|updated_at|)))
          ((is-error item)
           (format t "~a~t ~a~&"
                   (cl-ansi-text:red "FAILED")
                   (access:access item :|updated_at|)))
          (t
           (format t "~a~t ~a~&"
                   (access:access item :|status|)
                   (access:access item :|updated_at|))))))

#+(or nil)
(get-pipelines "vindarel%2Fabelujo")

(defun get-project-remote-url ()
  (let ((config (str:from-file ".git/config")))
    (cond
      ;; also doable with a call to git remotes -v
      ((not (str:containsp "[remote" config))
       (format nil "Does this repository has a remote?"))
      (t
       (error "todo :)")))))

(defun main ()
  (unless (uiop:command-line-arguments)
    (format *error-output* "Usage: pipelines-viewer username project")
    (uiop:quit 1))
  (let* ((args (uiop:command-line-arguments))
         (project-id (format nil "~a%2F~a" (first args) (second args))))
    (show-last-pipelines (get-pipelines project-id))))
