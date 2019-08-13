<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<!-- $Id: gen-install.xsl 4107 2019-06-15 15:26:23Z pierre $ -->

  <xsl:template name="process-install">
    <xsl:param name="instruction-tree"/>
    <xsl:param name="want-stats"/>
    <xsl:param name="root-seen"/>
    <xsl:param name="install-seen"/>
    <xsl:param name="test-seen"/>
    <xsl:param name="doc-seen"/>

<!-- Isolate the current instruction -->
    <xsl:variable name="current-instr" select="$instruction-tree[1]"/>

    <xsl:choose>
<!-- First, if we have an empty tree, close everything and exit -->
      <xsl:when test="not($current-instr)">
        <xsl:if test="$install-seen">
          <xsl:call-template name="end-install"/>
        </xsl:if>
        <xsl:if test="$root-seen">
          <xsl:call-template name="end-root"/>
        </xsl:if>
        <xsl:if test="$doc-seen and not($root-seen)">
          <xsl:call-template name="end-doc">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="$test-seen">
          <xsl:call-template name="end-test">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when><!-- empty tree -->
      <xsl:when test="$current-instr[@role='root' and @remap='test']">
        <xsl:if test="$install-seen">
          <xsl:call-template name="end-install"/>
        </xsl:if>
        <xsl:if test="$root-seen">
          <xsl:call-template name="end-root"/>
        </xsl:if>
        <xsl:if test="$doc-seen and not($root-seen)">
          <xsl:call-template name="end-doc">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($test-seen)">
          <xsl:call-template name="begin-test">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="begin-root"/>
        <xsl:choose>
          <xsl:when test="$want-stats">
            <xsl:apply-templates select="$current-instr" mode="root"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$current-instr"
                                 mode="root-comment-out"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="process-install">
          <xsl:with-param
             name="instruction-tree"
             select="$instruction-tree[position()>1]"/>
          <xsl:with-param name="want-stats" select="$want-stats"/>
          <xsl:with-param name="root-seen" select="boolean(1)"/>
          <xsl:with-param name="install-seen" select="boolean(0)"/>
          <xsl:with-param name="test-seen" select="boolean(1)"/>
          <xsl:with-param name="doc-seen" select="boolean(0)"/>
        </xsl:call-template>
      </xsl:when><!-- role="root" and remap="test" -->
      <xsl:when test="$current-instr[@role='root' and @remap='doc']">
        <xsl:if test="$test-seen">
          <xsl:call-template name="end-test">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="$doc-seen and not($root-seen)">
          <xsl:call-template name="end-doc">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($root-seen)">
          <xsl:call-template name="begin-root"/>
        </xsl:if>
        <xsl:if test="not($install-seen)">
          <xsl:call-template name="begin-install"/>
        </xsl:if>
        <xsl:apply-templates select="$current-instr"
                             mode="install-comment-out"/>
<!-- The above template ends with a commented line, so that if end-install
     adds a closing single quote, it will not be seen. Add a CR to prevent
     that -->
        <xsl:text>
</xsl:text>
        <xsl:call-template name="process-install">
          <xsl:with-param
             name="instruction-tree"
             select="$instruction-tree[position()>1]"/>
          <xsl:with-param name="want-stats" select="$want-stats"/>
          <xsl:with-param name="root-seen" select="boolean(1)"/>
          <xsl:with-param name="install-seen" select="boolean(1)"/>
          <xsl:with-param name="test-seen" select="boolean(0)"/>
          <xsl:with-param name="doc-seen" select="boolean(1)"/>
        </xsl:call-template>
      </xsl:when><!--role="root" and remap="doc" -->
      <xsl:when test="$current-instr[@role='root']">
        <xsl:choose>
          <xsl:when test="contains(string($current-instr),'useradd') or
                          contains(string($current-instr),'groupadd') or
                          contains(string($current-instr),'usermod') or
                          contains(string($current-instr),'icon-cache') or
                          contains(string($current-instr),'desktop-database') or
                          contains(string($current-instr),'compile-schemas') or
                          contains(string($current-instr),'query-loaders') or
                          contains(string($current-instr),'pam.d') or
                          contains(string($current-instr),'query-immodules')">
            <xsl:if test="$install-seen">
              <xsl:call-template name="end-install"/>
            </xsl:if>
            <xsl:if test="$test-seen">
              <xsl:call-template name="end-test">
                <xsl:with-param name="want-stats" select="$want-stats"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="$doc-seen and not($root-seen)">
              <xsl:call-template name="end-doc">
                <xsl:with-param name="want-stats" select="$want-stats"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="not($root-seen)">
              <xsl:call-template name="begin-root"/>
            </xsl:if>
            <xsl:apply-templates select="$current-instr" mode="root"/>
            <xsl:call-template name="process-install">
              <xsl:with-param
                 name="instruction-tree"
                 select="$instruction-tree[position()>1]"/>
              <xsl:with-param name="want-stats" select="$want-stats"/>
              <xsl:with-param name="root-seen" select="boolean(1)"/>
              <xsl:with-param name="install-seen" select="boolean(0)"/>
              <xsl:with-param name="test-seen" select="boolean(0)"/>
              <xsl:with-param name="doc-seen" select="boolean(0)"/>
            </xsl:call-template>
          </xsl:when><!-- end config as root -->
          <xsl:otherwise><!-- we have a true install instruction -->
            <xsl:if test="$test-seen">
              <xsl:call-template name="end-test">
                <xsl:with-param name="want-stats" select="$want-stats"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="$doc-seen and not($root-seen)">
              <xsl:call-template name="end-doc">
                <xsl:with-param name="want-stats" select="$want-stats"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="$want-stats and not($install-seen)">
              <xsl:if test="$root-seen">
                <xsl:call-template name="end-root"/>
              </xsl:if>
              <xsl:text>
echo Time before install: ${SECONDS} >> $INFOLOG</xsl:text>
              <xsl:apply-templates
                         select="$instruction-tree[@role='root']/userinput"
                         mode="destdir"/>
              <xsl:text>

echo Time after install: ${SECONDS} >> $INFOLOG
echo Size after install: $(sudo du -skx --exclude home /) >> $INFOLOG
</xsl:text>
              <xsl:if test="$root-seen">
                <xsl:call-template name="begin-root"/>
              </xsl:if>
            </xsl:if>
            <xsl:if test="not($root-seen)">
              <xsl:call-template name="begin-root"/>
            </xsl:if>
            <xsl:if test="not($install-seen)">
              <xsl:call-template name="begin-install"/>
            </xsl:if>
            <xsl:apply-templates select="$current-instr" mode="install"/>
            <xsl:call-template name="process-install">
              <xsl:with-param
                 name="instruction-tree"
                 select="$instruction-tree[position()>1]"/>
              <xsl:with-param name="want-stats" select="$want-stats"/>
              <xsl:with-param name="root-seen" select="boolean(1)"/>
              <xsl:with-param name="install-seen" select="boolean(1)"/>
              <xsl:with-param name="test-seen" select="boolean(0)"/>
              <xsl:with-param name="doc-seen" select="boolean(0)"/>
            </xsl:call-template>
          </xsl:otherwise><!-- end true install instruction -->
        </xsl:choose>
      </xsl:when><!-- role="root" and no remap -->
      <xsl:when test="$current-instr[@remap='test'] or
                      $current-instr/self::command">
        <xsl:if test="$install-seen">
          <xsl:call-template name="end-install"/>
        </xsl:if>
        <xsl:if test="$root-seen">
          <xsl:call-template name="end-root"/>
        </xsl:if>
        <xsl:if test="$doc-seen and not($root-seen)">
          <xsl:call-template name="end-doc">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($test-seen)">
          <xsl:if test="not($doc-seen)">
            <xsl:call-template name="end-make">
              <xsl:with-param name="want-stats" select="$want-stats"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="begin-test">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$want-stats">
            <xsl:apply-templates select="$current-instr"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$current-instr" mode="comment-out"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="process-install">
          <xsl:with-param
             name="instruction-tree"
             select="$instruction-tree[position()>1]"/>
          <xsl:with-param name="want-stats" select="$want-stats"/>
          <xsl:with-param name="root-seen" select="boolean(0)"/>
          <xsl:with-param name="install-seen" select="boolean(0)"/>
          <xsl:with-param name="test-seen" select="boolean(1)"/>
          <xsl:with-param name="doc-seen" select="boolean(0)"/>
        </xsl:call-template>
      </xsl:when><!-- no role, remap=test -->
      <xsl:when test="$current-instr[@remap='doc']">
        <xsl:if test="$install-seen">
          <xsl:call-template name="end-install"/>
        </xsl:if>
        <xsl:if test="$root-seen">
          <xsl:call-template name="end-root"/>
        </xsl:if>
        <xsl:if test="$test-seen">
          <xsl:call-template name="end-test">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($doc-seen) or $root-seen">
          <xsl:if test="not($test-seen) and not($root-seen)">
            <xsl:call-template name="end-make">
              <xsl:with-param name="want-stats" select="$want-stats"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="begin-doc">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$want-stats">
            <xsl:apply-templates select="$current-instr"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$current-instr" mode="comment-out"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="process-install">
          <xsl:with-param
             name="instruction-tree"
             select="$instruction-tree[position()>1]"/>
          <xsl:with-param name="want-stats" select="$want-stats"/>
          <xsl:with-param name="root-seen" select="boolean(0)"/>
          <xsl:with-param name="install-seen" select="boolean(0)"/>
          <xsl:with-param name="test-seen" select="boolean(0)"/>
          <xsl:with-param name="doc-seen" select="boolean(1)"/>
        </xsl:call-template>
      </xsl:when><!-- no role, remap="doc" -->
      <xsl:otherwise><!-- no role no remap -->
        <xsl:if test="$install-seen">
          <xsl:call-template name="end-install"/>
        </xsl:if>
        <xsl:if test="$root-seen">
          <xsl:call-template name="end-root"/>
        </xsl:if>
        <xsl:if test="$doc-seen and not($root-seen)">
          <xsl:call-template name="end-doc">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="$test-seen">
          <xsl:call-template name="end-test">
            <xsl:with-param name="want-stats" select="$want-stats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="$current-instr"/>
        <xsl:call-template name="process-install">
          <xsl:with-param
             name="instruction-tree"
             select="$instruction-tree[position()>1]"/>
          <xsl:with-param name="want-stats" select="$want-stats"/>
          <xsl:with-param name="root-seen" select="boolean(0)"/>
          <xsl:with-param name="install-seen" select="boolean(0)"/>
          <xsl:with-param name="test-seen" select="boolean(0)"/>
          <xsl:with-param name="doc-seen" select="boolean(0)"/>
        </xsl:call-template>
      </xsl:otherwise><!-- no role, no remap -->
    </xsl:choose>
  </xsl:template>

  <xsl:template match="userinput" mode="install-comment-out">
    <xsl:text>
</xsl:text>
    <xsl:call-template name="output-comment-out">
      <xsl:with-param name="out-string" select="string()"/>
      <xsl:with-param name="process" select="'install'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="userinput|command" mode="root-comment-out">
    <xsl:text>
</xsl:text>
    <xsl:call-template name="output-comment-out">
      <xsl:with-param name="out-string" select="string()"/>
      <xsl:with-param name="process" select="'root'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="userinput|command" mode="comment-out">
    <xsl:text>
</xsl:text>
    <xsl:call-template name="output-comment-out">
      <xsl:with-param name="out-string" select="string()"/>
      <xsl:with-param name="process" select="'none'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="userinput" mode="install">
    <xsl:text>
</xsl:text>
    <xsl:call-template name="output-install">
      <xsl:with-param name="out-string" select="string()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="output-comment-out">
<!-- Output instructions with each line commented out. The "process"
     parameter is:
        none: only output commented-out and remove ampersand
        root: output commented out and remove ampersand,
              with escaping of \, $, and `
        install: same + escape ' -->
    <xsl:param name="out-string"/>
    <xsl:param name="process"/>
    <xsl:choose>
      <xsl:when test="contains($out-string,'&#xA;')">
        <xsl:choose>
          <xsl:when test="$process='install'">
            <xsl:call-template name="output-install">
              <xsl:with-param
                        name="out-string"
                        select="concat('# ',
                                        substring-before($out-string,'&#xA;')
                                      )"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$process='root'">
            <xsl:call-template name="output-root">
              <xsl:with-param
                        name="out-string"
                        select="concat('# ',
                                        substring-before($out-string,'&#xA;')
                                      )"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="remove-ampersand">
              <xsl:with-param
                        name="out-string"
                        select="concat('# ',
                                        substring-before($out-string,'&#xA;')
                                      )"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="output-comment-out">
          <xsl:with-param
                    name="out-string"
                    select="substring-after($out-string,'&#xA;')"/>
          <xsl:with-param name="process" select="$process"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$process='install'">
            <xsl:call-template name="output-install">
              <xsl:with-param name="out-string"
                              select="concat('# ',$out-string)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$process='root'">
            <xsl:call-template name="output-root">
              <xsl:with-param name="out-string"
                              select="concat('# ',$out-string)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="remove-ampersand">
              <xsl:with-param name="out-string"
                              select="concat('# ',$out-string)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="end-make">
    <xsl:param name="want-stats"/>
    <xsl:if test="$want-stats">
      <xsl:text>

echo Time after make: ${SECONDS} >> $INFOLOG
echo Size after make: $(sudo du -skx --exclude home /) >> $INFOLOG</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="begin-doc">
    <xsl:param name="want-stats"/>
    <xsl:if test="$want-stats">
      <xsl:text>
echo Time before doc: ${SECONDS} >> $INFOLOG
</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="begin-test">
    <xsl:param name="want-stats"/>
    <xsl:if test="$want-stats">
      <xsl:text>
echo Time before test: ${SECONDS} >> $INFOLOG
</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="begin-root">
    <xsl:if test="$sudo='y'">
      <xsl:text>
sudo -E sh &lt;&lt; ROOT_EOF</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="begin-install">
    <xsl:if test="$wrap-install = 'y'">
      <xsl:text>
if [ -r "$JH_PACK_INSTALL" ]; then
  source $JH_PACK_INSTALL
  export -f wrapInstall
  export -f packInstall
fi
wrapInstall '</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="end-doc">
    <xsl:param name="want-stats"/>
    <xsl:if test="$want-stats">
      <xsl:text>

echo Time after doc: ${SECONDS} >> $INFOLOG
echo Size after doc: $(sudo du -skx --exclude home /) >> $INFOLOG</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="end-test">
    <xsl:param name="want-stats"/>
    <xsl:if test="$want-stats">
      <xsl:text>

echo Time after test: ${SECONDS} >> $INFOLOG
echo Size after test: $(sudo du -skx --exclude home /) >> $INFOLOG</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="end-root">
    <xsl:if test="$sudo='y'">
      <xsl:text>
ROOT_EOF</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="end-install">
    <xsl:if test="$del-la-files = 'y'">
      <xsl:call-template name="output-root">
        <xsl:with-param name="out-string" select="$la-files-instr"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$wrap-install = 'y'">
      <xsl:text>'&#xA;packInstall</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="output-install">
    <xsl:param name="out-string" select="''"/>
    <xsl:choose>
      <xsl:when test="starts-with($out-string, 'make ') or
                      contains($out-string,' make ') or
                      contains($out-string,'&#xA;make')">
        <xsl:call-template name="output-install">
          <xsl:with-param
               name="out-string"
               select="substring-before($out-string,'make ')"/>
        </xsl:call-template>
        <xsl:text>make -j1 </xsl:text>
        <xsl:call-template name="output-install">
          <xsl:with-param
               name="out-string"
               select="substring-after($out-string,'make ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($out-string,string($APOS))
                      and $wrap-install = 'y'">
        <xsl:call-template name="output-root">
          <xsl:with-param
               name="out-string"
               select="substring-before($out-string,string($APOS))"/>
        </xsl:call-template>
        <xsl:text>'\''</xsl:text>
        <xsl:call-template name="output-install">
          <xsl:with-param name="out-string"
                          select="substring-after($out-string,string($APOS))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-root">
          <xsl:with-param name="out-string" select="$out-string"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
