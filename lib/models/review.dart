class Review {
  final int id;
  final String name;
  final double rating;
  final String title;
  final String review;
  final bool approved;
  final String created_at;
  final String updated_at;

  Review(
      {this.id,
      this.name,
      this.rating,
      this.title,
      this.review,
      this.approved,
      this.created_at,
      this.updated_at});
}
