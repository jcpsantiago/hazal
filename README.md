
# hazal

AWS Sagemaker relies on docker containers for its pipelines.
Even though it's easy to test each container in isolation, it is harder to test the whole pipeline in one go.
`hazal` helps by orchestrating the communication between containers -- a Sagemaker emulator of sorts.

## TODO

- [ ] Define configuration structure
- [ ] Chain an arbitrary number of containers
