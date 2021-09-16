class CampaignArguments {
  final String campaignId,
      campaignName,
      from,
      to,
      status,
      totalPlayers,
      claimedPrizes;

  final int index;

  CampaignArguments(this.campaignId, this.campaignName, this.from, this.to,
      this.status, this.totalPlayers, this.claimedPrizes, this.index);
}
