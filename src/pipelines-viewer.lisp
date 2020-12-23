
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

(defun show-last-pipelines (data)
  (loop for item in (str:substring 0 5 data)
     do (cond
          ((is-success item)
           (format t "~a~t ~a~&"
                   (cl-ansi-text:green "OK")
                   (access:access item :|updated_at|))))))

#+(or nil)
(get-pipelines "vindarel%2Fabelujo")

(defun main ()
  (let ((project-id "vindarel%2Fabelujo"))
    (show-last-pipelines (get-pipelines project-id))))
