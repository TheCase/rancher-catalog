i##ELK Data Temp

This stack will tie into the master `elk-data` stack as a set of data nodes that can be used transfer and hold shards during the master stack upgrade process, thus preventing the loss of data that will no doubt occur should one follow the standard Rancher stack upgrade process.

###Instructions:

#### Stand up the new stack.

be sure the following stack parameters match your master ES data stack:

`external_link`: master Elasticsearch stack <stack_name>/<service_name>:<alias>

`cluster_name`: master Elasticsearch cluster name

Once the new nodes are up and attached to the cluster, you'll notice shards will start allocating to the new nodes.  Now we will intiate shard allocation rules to the stack to force all shards to live on the new nodes:

In Cerebro or Kibana REST tools:
type: `PUT`
path: `\*/\_settings`
request:
```
{
  "index.routing.allocation.require.stack": "elk-data-temp"
}
```

Once the shards have moved to the temp nodes (watch the progress in Cerebro), you can start the upgrade of the master nodes.  NOTE: when upgrading any Elasticasearch master nodes, please check the "Start before Stopping" batch setting and with a Batch Size of 1 and a Batch Interval of at least 300 seconds.

When all the main stack Elasticsearch nodes have been upgraded, you can remove the allocation rule so that all data will move off the temporary nodes:

In Cerebro or Kibana REST tools:
type: `PUT`
path: `\*/\_settings`
request:
```
{
  "index.routing.allocation.exclude.stack": "elk-data-temp"
}
```

Once the shards have been migrated, you may destroy the `elk-data-temp` stack.
