
(require "asdf")
(asdf:defsystem "pipelines-viewer"
  :version "0.1"
  :author "vindarel"
  :license "GPL3"
  :depends-on (
               :access
               ;; web client
               :dexador
               :str
               :jonathan

               ;; scripting
               :unix-opts
               :cl-ansi-text

               ;; dev
               :log4cl
               )
  :components ((:module "src/"
                :components
                ((:file "pipelines-viewer"))))

  :build-operation "program-op"
  :build-pathname "pipelines-viewer"
  :entry-point "pipelines-viewer::main"

  :description "View pipelines status"
  ;; :long-description
  ;; #.(read-file-string
  ;;    (subpathname *load-pathname* "README.md"))
  :in-order-to ((test-op (test-op "pipelines-viewer-test"))))

;; smaller binaries.
#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  (uiop:dump-image (asdf:output-file o c) :executable t :compression t))
