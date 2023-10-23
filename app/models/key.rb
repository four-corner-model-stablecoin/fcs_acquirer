class Key < ApplicationRecord
  belongs_to :did, optional: true

  def to_tapyrus_key
    return nil if jwk.nil?

    key = JSON::JWK.new(JSON.parse(jwk)).to_key

    if key.private_key.nil?
      Tapyrus::Key.new(pubkey: key.public_key.to_bn.to_s(16).downcase.encode('US-ASCII'), key_type: 0)
    else
      Tapyrus::Key.new(priv_key: key.private_key.to_s(16).downcase.encode('US-ASCII'), key_type: 0)
    end
  end
end
