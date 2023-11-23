# frozen_string_literal: true

acquirer_did = Did.create!(short_form: 'did:ion:EiDGrDx8oWprIY7lQglm2Vs6HC8LvM4OVxtI3QxKO9SB1A:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W3siaWQiOiJzaWduaW5nLWtleSIsInB1YmxpY0tleUp3ayI6eyJjcnYiOiJzZWNwMjU2azEiLCJrdHkiOiJFQyIsIngiOiJDaGQ5WlczNHl5azM0NzJZTm56VXk1Wll0eUtnWjU3ZkJ1djlTUXR4dnNJIiwieSI6Ik5CV3N5dVdWU3M4VVVfOFFVOWxzdkg3Vl9Dak5wNUhNR2hCQlMxLU5JTHcifSwicHVycG9zZXMiOlsiYXV0aGVudGljYXRpb24iXSwidHlwZSI6IkVjZHNhU2VjcDI1NmsxVmVyaWZpY2F0aW9uS2V5MjAxOSJ9XSwic2VydmljZXMiOltdfX1dLCJ1cGRhdGVDb21taXRtZW50IjoiRWlCQ3BXMDEzV2pfdGZaZUtTMWJwVmxOa1daamlEaHRjVHZqNWFndXd4d0xkdyJ9LCJzdWZmaXhEYXRhIjp7ImRlbHRhSGFzaCI6IkVpQ2N6UDFlc24xQWRGUF9peTJsRFcxZUNZNXBHb2djRWFPbTJNQktkOEV3SmciLCJyZWNvdmVyeUNvbW1pdG1lbnQiOiJFaUJLYTNwMmhzR21jcVViNDB4OTN3N1Zwa3BINEFxV3loTFVkUDBrQ3B6bUx3In19')
jwk = {
  "kty": "EC",
  "crv": "secp256k1",
  "x": "Chd9ZW34yyk3472YNnzUy5ZYtyKgZ57fBuv9SQtxvsI",
  "y": "NBWsyuWVSs8UU_8QU9lsvH7V_CjNp5HMGhBBS1-NILw",
  "d": "MMhVZD5bKCSQzaUw96yWQvkd6V6xYkaPpnRbeivn6k4"
}
Key.create!(did: acquirer_did, jwk: jwk.to_json)

# アンカリングだるいので long form
merchant_did = Did.create!(short_form: 'did:ion:EiCnFRH3V5Ik7yZnME3FnqFSDur9rfFbJVCzmL0Nyg8WQQ:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W3siaWQiOiJzaWduaW5nLWtleSIsInB1YmxpY0tleUp3ayI6eyJjcnYiOiJzZWNwMjU2azEiLCJrdHkiOiJFQyIsIngiOiJzUkhrWEFWSm14cS1yb1pqMGNTY3kweTlDUGl4MlRNM0xiQ0ZMYkN1SlU4IiwieSI6IkMtU1FiXzY0YXpMRUxuN1YyTHA4cVRGb1RUblUzZnAzSWY2TzB4bXpmcFUifSwicHVycG9zZXMiOlsiYXV0aGVudGljYXRpb24iXSwidHlwZSI6IkVjZHNhU2VjcDI1NmsxVmVyaWZpY2F0aW9uS2V5MjAxOSJ9XSwic2VydmljZXMiOltdfX1dLCJ1cGRhdGVDb21taXRtZW50IjoiRWlCVDRESzNWT0gwVXViaEhHOEZtdTNENFQzRmJvSzBxbzVpZS1INXVjQWh0USJ9LCJzdWZmaXhEYXRhIjp7ImRlbHRhSGFzaCI6IkVpQmhFeFc0Rmd0Q3JHVndGMXFOZ0t1NTFUTk5FUHktNG1NTGJ5VzA4R3d3S2ciLCJyZWNvdmVyeUNvbW1pdG1lbnQiOiJFaUJDYmFSYXY1R2V3SzZTQkN2aG9VMHFBSDEzWkYtZlZOU01jZ0NEUnFrUGJBIn19')
merchant = Merchant.create!(merchant_name: 'demo_merchant', did: merchant_did)
Wallet.create!(merchant:, balance: 0)
Account.create!(merchant:, balance: 0)

req = {
  "subjectDid": merchant_did.short_form,
  "issuerDid": acquirer_did.short_form,
  "issuerPrivateKey": jwk
}
response = Net::HTTP.post(
  URI("#{ENV['DID_SERVICE_URL']}/vc/create"),
  req.to_json,
  'Content-Type' => 'application/json'
)
body = JSON.parse(response.body)
jwt = body['vcJwt']
Vc.create!(merchant:, jwt:)

if Glueby::AR::SystemInformation.synced_block_height.nil?
  Glueby::AR::SystemInformation.create!(info_key: 'synced_block_number', info_value: '0')
end

address = Glueby::Internal::RPC.client.getnewaddress
aggregate_private_key = ENV['TAPYRUS_AUTHORITY_KEY']
Glueby::Internal::RPC.client.generatetoaddress(1, address, aggregate_private_key)

latest_block_num = Glueby::Internal::RPC.client.getblockcount
synced_block = Glueby::AR::SystemInformation.synced_block_height
(synced_block.int_value + 1..latest_block_num).each do |height|
  Glueby::BlockSyncer.new(height).run
  synced_block.update(info_value: height.to_s)
end
