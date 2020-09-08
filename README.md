
# hazal🧙‍♀️

AWS Sagemaker relies on docker containers for its pipelines.
This means it's possible to create custom containers using e.g. other languages than Python or algorithms not available off-the-shelf in AWS.
Even though it's easy to test each container in isolation, it is harder to test the whole pipeline in one go.
`hazal` helps by orchestrating the communication between containers -- a Sagemaker emulator of sorts.

## TODO

- [ ] Define configuration structure
- [ ] Chain an arbitrary number of containers
- [ ] Differentiate between single and multi-model containers
- [ ] Send request to load model, if necessary
