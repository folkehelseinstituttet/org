context("InitialiseProject")

test_that("Create org::PROJ$SHARED_TODAY", {
  AllowFileManipulationFromInitialiseProject()
  InitialiseProject(
    HOME = tempdir(),
    SHARED = tempdir(),
    RAW = tempdir()
  )

  testthat::expect_equal(TRUE, dir.exists(org::PROJ$SHARED_TODAY))
})

test_that("Error due to multiple non-existed folders", {
  AllowFileManipulationFromInitialiseProject()

  testthat::expect_error(
    InitialiseProject(
      HOME = c("dfsdfoij323423", "sdfd232323"),
      SHARED = tempdir(),
      RAW = tempdir()
    )
  )
})


test_that("Works due to multiple non-existed folders", {
  AllowFileManipulationFromInitialiseProject()
  InitialiseProject(
    HOME = c(tempdir(), "sdfd232323"),
    SHARED = tempdir(),
    RAW = tempdir()
  )

  testthat::expect_equal(TRUE, dir.exists(org::PROJ$SHARED_TODAY))
})


test_that("computer_id identifying correct order", {
  AllowFileManipulationFromInitialiseProject()
  InitialiseProject(
    HOME = c("sdfd232323", tempdir()),
    SHARED = tempdir(),
    RAW = tempdir()
  )

  testthat::expect_equal(2, PROJ$computer_id)
})

test_that("Sources multiple code folders that do exist", {
  AllowFileManipulationFromInitialiseProject()

  dir.create(file.path(tempdir(), "x1"))
  dir.create(file.path(tempdir(), "y1"))

  testthat::expect_message(
    InitialiseProject(
      HOME = tempdir(),
      RAW = tempdir(),
      folders_to_be_sourced = c("x1", "y1")
    ),
    "*Sourcing all code inside*"
  )
})

test_that("Sources multiple code folders that dont exist", {
  AllowFileManipulationFromInitialiseProject()

  testthat::expect_warning(
    InitialiseProject(
      HOME = tempdir(),
      RAW = tempdir(),
      folders_to_be_sourced = c("x2", "y2")
    ),
    "*Creating it now."
  )
})
