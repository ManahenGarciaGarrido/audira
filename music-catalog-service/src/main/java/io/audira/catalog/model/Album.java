package io.audira.catalog.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "albums")
@DiscriminatorValue("ALBUM")
@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class Album extends Product {

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "album_genres", joinColumns = @JoinColumn(name = "album_id"))
    @Column(name = "genre_id")
    private Set<Long> genreIds = new HashSet<>();

    @Column(name = "release_date")
    private LocalDate releaseDate;

    // Price is calculated based on song prices with discount
    // Not stored directly - calculated when needed
    @Transient
    private Double discountPercentage = 0.15; // 15% discount by default

    @Override
    public String getProductType() {
        return "ALBUM";
    }
}
