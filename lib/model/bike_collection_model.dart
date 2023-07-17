class BikeCollectionModel {
  String? shortBikeId;
  String? uuid;
  String? tenantId;
  String? locationId;
  bool status;

  BikeCollectionModel({
    this.shortBikeId,
    this.uuid,
    this.tenantId,
    this.locationId,
    this.status = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['short_bike_id'] = shortBikeId;
    data['tenant_id'] = tenantId;
    data['location_id'] = locationId;
    data['uuid'] = uuid;
    data['status'] = status;
    return data;
  }
}
