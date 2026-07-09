package com.vithey.profile.repository;

import com.vithey.profile.entity.Profile;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {

  @Query("""
      SELECT profile
      FROM Profile profile
      WHERE LOWER(profile.fullName) LIKE LOWER(CONCAT('%', :search, '%'))
         OR LOWER(profile.university) LIKE LOWER(CONCAT('%', :search, '%'))
         OR LOWER(profile.major) LIKE LOWER(CONCAT('%', :search, '%'))
      ORDER BY profile.fullName ASC
      """)
  Page<Profile> searchByFullName(@Param("search") String search, Pageable pageable);
}
