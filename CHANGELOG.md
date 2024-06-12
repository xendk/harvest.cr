# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.3.0 - 2024-06-12

### Added

- Block variants of fetching methods. Currently just calls the
  non-block variant, but these could fetch on demand instead in the
  future.

## 0.2.0 - 2024-06-02

### Added

- `updated_since` argument to all fetching methods.

## 0.1.0 - 2024-05-28

### Added

- #time_entries, #users, #projects and #tasks. All uses cursors
  to fetch all results using multiple requests, if needed.
