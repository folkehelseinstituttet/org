context("InitialiseProject")

test_that("Create org::PROJ$SHARED_TODAY", {
  AllowFileManipulationFromInitialiseProject()
  InitialiseProject(
    HOME=tempdir(),
    SHARED=tempdir(),
    RAW=tempdir()
  )

  expect_equal(TRUE,dir.exists(org::PROJ$SHARED_TODAY))
})

