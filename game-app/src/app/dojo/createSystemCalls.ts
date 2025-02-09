import type { SetupNetworkResult } from "./setupNetwork";
// import { Account, InvokeTransactionReceiptResponse, shortString } from "starknet";
// import { EntityIndex, getComponentValue, setComponent } from "@latticexyz/recs";
// import { uuid } from "@latticexyz/utils";
import type { ClientComponents } from "./createClientComponents";
import { Account } from "starknet";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

enum EntryPoints {
    CREATE_GAME = "create_game_system",
    CREATE_CARD = "create_card_system",
    ATTACK = "attack_system",
    END_TURN = "end_turn_system",
    PLACE_CARD = "place_card_system",
}

interface SystemCall {
    account: Account;
}

interface CreateGame extends SystemCall {
    player_2_address: string;
}

export function createSystemCalls(
    { execute }: SetupNetworkResult,
    { }: ClientComponents
) {

    // Add Systems here:
    const create_game = async ({ account, player_2_address }: CreateGame) => {

        try {
            const tx = await execute(account, EntryPoints.CREATE_GAME, [player_2_address]);
            const receipt = await account.waitForTransaction(tx.transaction_hash, { retryInterval: 100 })

            console.log(receipt)
        } catch (e) {
            console.log(e)
        }




        return
    };

    // const create_card = async ({ }) => { };

    // const attack = async () => { }

    // const end_turn = async () => { }

    // const place_card = async () => { }

    return {
        create_game
    };
}
