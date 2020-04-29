class queryResultsAggregationSettings {
    [string] $aggregationKind

    queryResultsAggregationSettings ($aggregationKind) {
        $this.aggregationKind = $aggregationKind
    }
}
