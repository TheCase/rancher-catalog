## Elasticsearch Clown Car

This stack will tie into a `elk-data` stack as a set of master/data nodes that can be used transfer and hold shards during the stack upgrade process, thus preventing the loss of data that will, no doubt, occur should one follow the standard Rancher stack upgrade process.

### Instructions:

#### Stand up the ClownCar stack

Ensure the following stack parameters match your master ES data stack:

- `Scale` This should match in node count, plus storage space per node
- `external_link` Elasticsearch Rancher stack *stack_name*/*service_name*
- `cluster_name` Elasticsearch cluster name

#### Verify attachment to main ES stack
Once the new ClownCar nodes are up and attached to the cluster, you'll notice shards will start allocating to the new nodes.  We will instantiate shard allocation rules to the stack to force all shards to live on the new nodes:

#### Migrate the shards to the ClownCar silos

In Cerebro or Kibana REST tools:
```
type: PUT
path: */_settings
request:
{
  "index.routing.allocation.require.stack_id": "_clowncar"
}
```
#### Upgrade the target ES stack

Once the shards have moved to the temp nodes (watch the progress in Cerebro - don't forget the .special indices!), you can start the upgrade of the master nodes.

**Suggestion**: when upgrading any Elasticsearch master nodes, please **check** the `Start before Stopping` batch setting and with a `Batch Size` of **1** and a `Batch Interval` of at least **60** seconds.

When all of the main stack Elasticsearch nodes have been upgraded, you can remove the allocation rule so that all data will move off the temporary nodes:

#### Enable allocation awareness
`stack_id`
#### Relocate shards to upgraded nodes

In Cerebro or Kibana REST tools:
```
type: PUT
path: */_settings
request:
{
  "index.routing.allocation.require.stack_id": "*",
}
```

#### Finish

Once the all shards have been migrated, you may destroy the `elasticsearch-clowncar` stack.
