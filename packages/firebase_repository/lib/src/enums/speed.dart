enum Speed {
  balance,
  turbo,
  silent,
}

extension SpeedX on Speed {
  bool get isBalance => this == Speed.balance;
  bool get isTurbo => this == Speed.turbo;
  bool get isSilent => this == Speed.silent;

  double mapSpeedToVal() {
    if (this.isBalance) return 0.5;
    if (this.isSilent) return 0.3;
    if (this.isTurbo)
      return 0.9;
    else
      return 0.5;
  }
}
