(declare-project
  :name "hazal"
  :description "Test a Sagemaker pipeline from the comfort of your laptop"
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/joy-framework/http"]
  :author "João Santiago"
  :license "MIT"
  :url ""
  :repo "https://github.com/jcpsantiago/hazal")

(declare-executable
  :name "hazal"
  :entry "main.janet")

(phony "server" []
  (os/shell "janet main.janet"))

(phony "watch" []
  (os/shell "find . -name '*.janet' | entr -r -d janet main.janet"))
