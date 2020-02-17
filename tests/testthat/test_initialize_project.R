context("initialize")

test_that("Create org::project$results_today", {
  initialize_project(
    home = tempdir(),
    results = tempdir(),
    raw = tempdir(),
    folders_to_be_sourced = NULL,
    create_folders = TRUE
  )

  testthat::expect_equal(TRUE, dir.exists(org::project$results_today))
})

test_that("Error due to multiple non-existed folders", {
  testthat::expect_error(
    initialize_project(
      home = c("dfsdfoij323423", "sdfd232323"),
      results = tempdir(),
      raw = tempdir()
    )
  )
})


test_that("Works due to multiple non-existed folders", {
  initialize_project(
    home = c(tempdir(), "sdfd232323"),
    results = tempdir(),
    raw = tempdir(),
    folders_to_be_sourced = NULL,
    create_folders = TRUE
  )

  testthat::expect_equal(TRUE, dir.exists(org::project$results_today))
})


test_that("computer_id identifying correct order", {
  initialize_project(
    home = c("sdfd232323", tempdir()),
    results = tempdir(),
    raw = tempdir(),
    folders_to_be_sourced = NULL,
    create_folders = TRUE
  )

  testthat::expect_equal(2, org::project$computer_id)
})

test_that("Sources multiple code folders that do exist", {
  dir.create(file.path(tempdir(), "x1"))
  dir.create(file.path(tempdir(), "y1"))

  testthat::expect_message(
    initialize_project(
      home = tempdir(),
      raw = tempdir(),
      folders_to_be_sourced = c("x1", "y1"),
      create_folders = TRUE
    ),
    "*Sourcing all code inside*"
  )
})

test_that("Sources multiple code folders that dont exist", {
  unlink(tempdir(), recursive = TRUE, force = TRUE)
  dir.create(tempdir())
  testthat::expect_warning(
    initialize_project(
      home = tempdir(),
      raw = tempdir(),
      folders_to_be_sourced = c("x2", "y2"),
      create_folders = TRUE
    ),
    "*Creating it now."
  )
})
