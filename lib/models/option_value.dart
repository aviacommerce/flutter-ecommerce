class OptionValue {
  final int id;
  final String name;
  final String presentation;
  final int position;
  final String optionTypeName;
  final int optionTypeId;
  final String optionTypePresentation;

  OptionValue(
      {this.id,
      this.name,
      this.optionTypeId,
      this.optionTypeName,
      this.optionTypePresentation,
      this.position,
      this.presentation});
}
