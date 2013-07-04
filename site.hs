--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Control.Applicative ((<$>))
import           Control.Monad
import           Data.Monoid         (mappend, mconcat, (<>))
import           Hakyll

--------------------------------------------------------------------------------
config :: Configuration
config = defaultConfiguration
  { deployCommand = "rsync -av _site/ byorgey@eniac.seas.upenn.edu:html/farm13" }

main :: IO ()
main = hakyllWith config $ do
    match "images/*.jpg" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "templates/*" $ compile templateCompiler

    match (fromList . map (fromFilePath . snd) $ subSections) $ do
        compile $ pandocCompiler
              >>= loadAndApplyTemplate "templates/section.html" defaultContext
              >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            let indexCtx = mconcat
                         . map (\(fld,file) -> field fld (\_ -> subCompiler file))
                         $ subSections

--                navCtx   = field "nav" (\_ -> navList)

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

subSections = [ ("about", "about.markdown")
              , ("dates", "dates.markdown")
              , ("cfp", "cfp.markdown")
              , ("cfd", "cfd.markdown")
              , ("committee", "committee.markdown")
              , ("organization", "organization.markdown")
              ]

--------------------------------------------------------------------------------

subCompiler :: String -> Compiler String
subCompiler file = itemBody <$> load (fromFilePath file)

-- argh, can't figure out how to make this work
--
-- navList :: Compiler String
-- navList = do
--   let sections   = map fst subSections
--   navTpl <- loadBody "templates/nav-item.html"
--   list   <- applyTemplateList navTpl defaultCtx (make
--   return list

-- newsList :: ([Item String] -> [Item String]) -> Compiler String
-- newsList sortFilter = do
--     news    <- sortFilter <$> loadAll "news/*"
--     itemTpl <- loadBody "templates/news-item.html"
--     list    <- applyTemplateList itemTpl newsCtx news
--     return list
