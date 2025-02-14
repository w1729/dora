import { newMockEvent } from "matchstick-as"
import { ethereum, Bytes, BigInt, Address } from "@graphprotocol/graph-ts"
import {
  OperatorRegistered,
  RandomnessFulfilled,
  RandomnessRequested
} from "../generated/ZKVRF/ZKVRF"

export function createOperatorRegisteredEvent(
  operatorPublicKey: Bytes
): OperatorRegistered {
  let operatorRegisteredEvent = changetype<OperatorRegistered>(newMockEvent())

  operatorRegisteredEvent.parameters = new Array()

  operatorRegisteredEvent.parameters.push(
    new ethereum.EventParam(
      "operatorPublicKey",
      ethereum.Value.fromFixedBytes(operatorPublicKey)
    )
  )

  return operatorRegisteredEvent
}

export function createRandomnessFulfilledEvent(
  requestId: BigInt,
  operatorPublicKey: Bytes,
  requester: Address,
  nonce: BigInt,
  randomness: BigInt
): RandomnessFulfilled {
  let randomnessFulfilledEvent = changetype<RandomnessFulfilled>(newMockEvent())

  randomnessFulfilledEvent.parameters = new Array()

  randomnessFulfilledEvent.parameters.push(
    new ethereum.EventParam(
      "requestId",
      ethereum.Value.fromUnsignedBigInt(requestId)
    )
  )
  randomnessFulfilledEvent.parameters.push(
    new ethereum.EventParam(
      "operatorPublicKey",
      ethereum.Value.fromFixedBytes(operatorPublicKey)
    )
  )
  randomnessFulfilledEvent.parameters.push(
    new ethereum.EventParam("requester", ethereum.Value.fromAddress(requester))
  )
  randomnessFulfilledEvent.parameters.push(
    new ethereum.EventParam("nonce", ethereum.Value.fromUnsignedBigInt(nonce))
  )
  randomnessFulfilledEvent.parameters.push(
    new ethereum.EventParam(
      "randomness",
      ethereum.Value.fromUnsignedBigInt(randomness)
    )
  )

  return randomnessFulfilledEvent
}

export function createRandomnessRequestedEvent(
  requestId: BigInt,
  operatorPublicKey: Bytes,
  requester: Address,
  minBlockConfirmations: i32,
  callbackGasLimit: BigInt,
  nonce: BigInt
): RandomnessRequested {
  let randomnessRequestedEvent = changetype<RandomnessRequested>(newMockEvent())

  randomnessRequestedEvent.parameters = new Array()

  randomnessRequestedEvent.parameters.push(
    new ethereum.EventParam(
      "requestId",
      ethereum.Value.fromUnsignedBigInt(requestId)
    )
  )
  randomnessRequestedEvent.parameters.push(
    new ethereum.EventParam(
      "operatorPublicKey",
      ethereum.Value.fromFixedBytes(operatorPublicKey)
    )
  )
  randomnessRequestedEvent.parameters.push(
    new ethereum.EventParam("requester", ethereum.Value.fromAddress(requester))
  )
  randomnessRequestedEvent.parameters.push(
    new ethereum.EventParam(
      "minBlockConfirmations",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(minBlockConfirmations))
    )
  )
  randomnessRequestedEvent.parameters.push(
    new ethereum.EventParam(
      "callbackGasLimit",
      ethereum.Value.fromUnsignedBigInt(callbackGasLimit)
    )
  )
  randomnessRequestedEvent.parameters.push(
    new ethereum.EventParam("nonce", ethereum.Value.fromUnsignedBigInt(nonce))
  )

  return randomnessRequestedEvent
}
