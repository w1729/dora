import {
  OperatorRegistered as OperatorRegisteredEvent,
  RandomnessFulfilled as RandomnessFulfilledEvent,
  RandomnessRequested as RandomnessRequestedEvent
} from "../generated/ZKVRF/ZKVRF"
import {
  OperatorRegistered,
  RandomnessFulfilled,
  RandomnessRequested
} from "../generated/schema"

export function handleOperatorRegistered(event: OperatorRegisteredEvent): void {
  let entity = new OperatorRegistered(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.operatorPublicKey = event.params.operatorPublicKey

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRandomnessFulfilled(
  event: RandomnessFulfilledEvent
): void {
  let entity = new RandomnessFulfilled(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.requestId = event.params.requestId
  entity.operatorPublicKey = event.params.operatorPublicKey
  entity.requester = event.params.requester
  entity.nonce = event.params.nonce
  entity.randomness = event.params.randomness

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRandomnessRequested(
  event: RandomnessRequestedEvent
): void {
  let entity = new RandomnessRequested(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.requestId = event.params.requestId
  entity.operatorPublicKey = event.params.operatorPublicKey
  entity.requester = event.params.requester
  entity.minBlockConfirmations = event.params.minBlockConfirmations
  entity.callbackGasLimit = event.params.callbackGasLimit
  entity.nonce = event.params.nonce

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
