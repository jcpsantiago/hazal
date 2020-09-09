
# hazal🧙‍♀️

[AWS Sagemaker](https://aws.amazon.com/sagemaker/) relies on docker containers for its pipelines.
This means it's possible to create custom containers using e.g. other languages than Python or algorithms not available off-the-shelf in AWS.
Even though it's easy to test each container in isolation, it is harder to test the whole pipeline in one go.
`hazal` helps by orchestrating the communication between containers.

The usual disclaimers of beta-quality software apply.

## Usage

`hazal` expects a configuration file with the following structure:
```clojure
[{:type "single"
  :container "sagemaker-pre"
  :port 8888}
{:type "multi"
 :container "sagemaker-inf"
 :port 9999}]
```

Such a file could live in the main repository of a project e.g. where models are trained locally.
Then, to use `hazal` and test the pipeline:
- Launch the docker containers (`hazal` won't do this for now)
- Launch `hazal` with `janet main.janet <path to config>` (or build the binary with `jpm build`)
- `POST` the payload expected by the first sagemaker container to `localhost:9001/pipeline`, or wherever `hazal` is running

## TODO

- [x] Define configuration structure
- [x] Chain an arbitrary number of containers
- [ ] Differentiate between single and multi-model containers
- [ ] Send request to load model, if necessary

## See also
- [MultiModel server in R](https://github.com/jcpsantiago/sagemaker-multimodel-R)
- [MultiModel server in Clojure](https://github.com/jcpsantiago/sagemaker-multimodel-clj)
