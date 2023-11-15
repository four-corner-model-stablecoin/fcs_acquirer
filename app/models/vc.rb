# frozen_string_literal: true

# VerifiableCredentialsモデル
# 加盟店に対し発行したVCを管理する
# MEMO: とりあえずJWTでそのまま保存
class Vc < ApplicationRecord
  validates :jwt, presence: true

  belongs_to :merchant
end
