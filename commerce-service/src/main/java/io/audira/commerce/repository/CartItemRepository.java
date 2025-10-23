package io.audira.commerce.repository;

import io.audira.commerce.model.CartItem;
import io.audira.commerce.model.ItemType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {

    List<CartItem> findByCartId(Long cartId);

    Optional<CartItem> findByCartIdAndItemTypeAndItemId(Long cartId, ItemType itemType, Long itemId);

    void deleteByCartId(Long cartId);
}
