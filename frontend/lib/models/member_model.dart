class Member {
  final String nickname;
  final int totalPrice;
  final int deposit;
  final int profitAndLoss;
  final int rank;
  final String rankSaveTime;
  final String roi;

  Member({
    required this.nickname,
    required this.totalPrice,
    required this.deposit,
    required this.profitAndLoss,
    required this.rank,
    required this.rankSaveTime,
    required this.roi,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      nickname: json['nickname'],
      totalPrice: json['totalPrice'],
      deposit: json['deposit'],
      profitAndLoss: json['profitAndLoss'],
      rank: json['rank'],
      rankSaveTime: json['rankSaveTime'],
      roi: json['roi'],
    );
  }
}
