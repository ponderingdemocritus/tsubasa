use array::ArrayTrait;
use option::{Option, OptionTrait};
use serde::Serde;
use starknet::ContractAddress;
use starknet::testing::set_contract_address;
use dojo::world::IWorldDispatcherTrait;
use clone::Clone;
use debug::PrintTrait;
use tsubasa::components::{Game, Player};
use tsubasa::systems::{create_game_system, attack_system, end_turn_system, place_card_system};
use tsubasa::tests::utils::{get_players, create_game, spawn_world};

#[test]
#[available_gas(30000000)]
fn test_end_turn() {
    let world = spawn_world();
    let (player1, player2, _) = get_players();
    let game_id = create_game(:world, :player1, :player2);
    // card_id.low, card_id.high, Roles::Goalkeeper
    let mut place_card_calldata = array![game_id, 0, 0, 0];
    world.execute('place_card_system', place_card_calldata);

    let mut attack_calldata = array![0];
    world.execute('attack_system', attack_calldata);

    let end_turn_calldata = array![game_id];
    world.execute('end_turn_system', end_turn_calldata);

    let game = get!(world, game_id, Game);

    let expected_game = Game {
        game_id,
        player1,
        player2,
        player1_score: 0,
        player2_score: 0,
        turn: 1,
        outcome: Option::None
    };

    assert(game.game_id == expected_game.game_id, 'invalid game_id');
    assert(game.player1_score == expected_game.player1_score, 'Wrong player1 score');
    assert(game.player2_score == expected_game.player2_score, 'Wrong player2 score');
    assert(game.turn == expected_game.turn, 'Wrong turn value');
    // Check that option is None
    assert(game.outcome.is_none(), 'Wrong outcome value');

    let player = get!(world, (game_id, player1), Player);
    // Check that player energy is correclty incremented at the end of each turn.
    assert(player.remaining_energy == 2, 'Wrong player energy value');
}

#[test]
#[should_panic]
#[available_gas(30000000)]
fn test_end_turn_wrong_player() {
    let world = spawn_world();
    let (player1, player2, _) = get_players();
    let game_id = create_game(:world, :player1, :player2);
    set_contract_address(player2);
    let end_turn_calldata = array![game_id];
    world.execute('end_turn_system', end_turn_calldata);
}

#[test]
#[should_panic]
#[available_gas(30000000)]
fn test_end_turn_right_player_then_wrong_player() {
    let world = spawn_world();
    let (player1, player2, _) = get_players();
    let game_id = create_game(:world, :player1, :player2);
    set_contract_address(player1);
    let end_turn_calldata = array![game_id];
    world.execute('end_turn_system', (@end_turn_calldata).clone());
    world.execute('end_turn_system', end_turn_calldata);
}

#[test]
#[available_gas(30000000)]
fn test_end_turn_right_players_twice() {
    let world = spawn_world();
    let (player1, player2, _) = get_players();
    let game_id = create_game(:world, :player1, :player2);
    set_contract_address(player1);
    let end_turn_calldata = array![game_id];
    world.execute('end_turn_system', (@end_turn_calldata).clone());
    set_contract_address(player2);
    world.execute('end_turn_system', (@end_turn_calldata).clone());
    set_contract_address(player1);
    world.execute('end_turn_system', (@end_turn_calldata).clone());
    set_contract_address(player2);
    world.execute('end_turn_system', end_turn_calldata);
}

