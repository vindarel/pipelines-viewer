
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
     with the-most-recent-pipeline-failed = (is-error (first data))
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
                   (access:access item :|updated_at|))))
     finally
       (when the-most-recent-pipeline-failed
         (format t "~%See your failing pipeline here: ~a~&" (access:access (first data) :|web_url|)))))

#+(or nil)
(get-pipelines "vindarel%2Fabelujo")
#+(or nil)
(show-last-pipelines (get-pipelines "vindarel%2Fabelujo"))

(defun run (args)
  "Optional arguments: username project. Otherwise, extract them from the first .git/config remote URL."
  (let* (project-id)
    (cond
      ;; We have CLI args.
      (args
       (setf project-id (format nil "~a%2F~a" (first args) (second args))))
      ;; Read the .git/config, consider the first remote URL.
      (t
       (let* ((remote-url (first-remote-url))
              (user/project (get-user/project remote-url)))
         (setf project-id (format nil "~a%2F~a" (first user/project) (second user/project))))))

    (show-last-pipelines (get-pipelines project-id))))

(defun main ()
  (run (uiop:command-line-arguments)))
