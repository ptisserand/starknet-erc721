# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.1.0 (token/erc721/ERC721_Mintable_Burnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
)

from openzeppelin.token.erc721.library import (
    ERC721_name,
    ERC721_symbol,
    ERC721_balanceOf,
    ERC721_ownerOf,
    ERC721_getApproved,
    ERC721_isApprovedForAll,
    ERC721_mint,
    ERC721_burn,
    ERC721_initializer,
    ERC721_approve,
    ERC721_setApprovalForAll,
    ERC721_transferFrom,
    ERC721_safeTransferFrom,
)

from openzeppelin.token.erc721_enumerable.library import (
    ERC721_Enumerable_burn,
    ERC721_Enumerable_initializer,
    ERC721_Enumerable_mint,
    ERC721_Enumerable_tokenOfOwnerByIndex,
)

@storage_var
func token_id_storage() -> (token_id_storage: Uint256):
end


@storage_var
func token_sex(token_id: Uint256) -> (sex : felt):
end

@storage_var
func token_legs(token_id: Uint256) -> (legs: felt):
end

@storage_var
func token_wings(token_id: Uint256) -> (legs: felt):
end

#
# Constructor
#

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        name: felt,
        symbol: felt,
        to_: felt
    ):
    ERC721_initializer(name, symbol)
    ERC721_Enumerable_initializer()
    # first token must be owned by evaluator contract
    let to = to_
    let token_id: Uint256 = Uint256(1, 0)
    token_id_storage.write(token_id)
    mint_animal(to, 2, 1, 2)
    return ()
end

#
# Getters
#


@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC721_name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC721_symbol()
    return (symbol)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC721_balanceOf(owner)
    return (balance)
end

@view
func ownerOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (owner: felt):
    let (owner: felt) = ERC721_ownerOf(tokenId)
    return (owner)
end

@view
func getApproved{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (approved: felt):
    let (approved: felt) = ERC721_getApproved(tokenId)
    return (approved)
end

@view
func isApprovedForAll{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, operator: felt) -> (isApproved: felt):
    let (isApproved: felt) = ERC721_isApprovedForAll(owner, operator)
    return (isApproved)
end

@view
func get_animal_characteristics{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id : Uint256) -> (sex : felt, legs : felt, wings : felt):
    let (sex: felt) = token_sex.read(token_id)
    let (legs: felt) = token_legs.read(token_id)
    let (wings: felt) = token_wings.read(token_id)
    return (sex, legs, wings)
end

@view
func token_of_owner_by_index{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(account : felt, index_ : felt) -> (token_id : Uint256):
    let index: Uint256 = Uint256(index_, 0)
    let token_id: Uint256 = ERC721_Enumerable_tokenOfOwnerByIndex(account, index)
    return (token_id)
end
#
# Externals
#

@external
func approve{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, tokenId: Uint256):
    ERC721_approve(to, tokenId)
    return ()
end

@external
func setApprovalForAll{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(operator: felt, approved: felt):
    ERC721_setApprovalForAll(operator, approved)
    return ()
end

@external
func transferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256
    ):
    ERC721_transferFrom(from_, to, tokenId)
    return ()
end

@external
func safeTransferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256,
        data_len: felt,
        data: felt*
    ):
    ERC721_safeTransferFrom(from_, to, tokenId, data_len, data)
    return ()
end

@external
func declare_animal{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(sex : felt, legs : felt, wings : felt) -> (token_id : Uint256):
    let (sender_address) = get_caller_address()
    let token_id: Uint256 = mint_animal(sender_address, sex, legs, wings)
    return (token_id)
end

@external
func declare_dead_animal{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id : Uint256):
    ERC721_Enumerable_burn(token_id)
    token_sex.write(token_id, 0)
    token_legs.write(token_id, 0)
    token_wings.write(token_id, 0)
    return ()
end

#
# Internals
#
func mint_animal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(to_: felt, sex: felt, legs: felt, wings: felt) -> (token_id: Uint256):
    let to = to_
    let token_id: Uint256 = token_id_storage.read()
    ERC721_Enumerable_mint(to, token_id)
    let token_id: Uint256 = token_id_storage.read()
    token_sex.write(token_id, sex)
    token_legs.write(token_id, legs)
    token_wings.write(token_id, wings)
    let one_as_uint256 : Uint256 = Uint256(1, 0)
    let (new_token_id, _) = uint256_add(token_id, one_as_uint256)
    token_id_storage.write(new_token_id)
    return (token_id)
end