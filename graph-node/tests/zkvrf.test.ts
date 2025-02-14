import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Bytes, BigInt, Address } from "@graphprotocol/graph-ts"
import { OperatorRegistered } from "../generated/schema"
import { OperatorRegistered as OperatorRegisteredEvent } from "../generated/ZKVRF/ZKVRF"
import { handleOperatorRegistered } from "../src/zkvrf"
import { createOperatorRegisteredEvent } from "./zkvrf-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let operatorPublicKey = Bytes.fromI32(1234567890)
    let newOperatorRegisteredEvent =
      createOperatorRegisteredEvent(operatorPublicKey)
    handleOperatorRegistered(newOperatorRegisteredEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("OperatorRegistered created and stored", () => {
    assert.entityCount("OperatorRegistered", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "OperatorRegistered",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "operatorPublicKey",
      "1234567890"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
